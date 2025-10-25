# frozen_string_literal: true

module GuestSpot
  class PostsController < ::ApplicationController
    requires_plugin 'discourse-guest-spot'

    before_action :ensure_logged_in, only: [:create, :update, :destroy]
    before_action :find_topic, only: [:show, :update, :destroy]

    def index
      category_id = CategoryHelper.public_feed_category_id
      raise Discourse::NotFound unless category_id

      topics = Topic
        .where(category_id: category_id)
        .where(deleted_at: nil)
        .includes(:user, posts: :uploads)
        .order(created_at: :desc)
        .limit(50)

      pinned_topics = Topic
        .where(category_id: category_id)
        .where(deleted_at: nil)
        .where.not(pinned_at: nil)
        .includes(:user, posts: :uploads)
        .order(created_at: :desc)

      render json: {
        posts: serialize_data(topics, GuestSpotPostSerializer),
        pinned: serialize_data(pinned_topics, GuestSpotPostSerializer)
      }
    end

    def show
      render_serialized(@topic, GuestSpotPostSerializer)
    end

    def by_user
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user

      category_id = CategoryHelper.public_feed_category_id
      raise Discourse::NotFound unless category_id

      topics = Topic
        .where(category_id: category_id, user_id: user.id)
        .where(deleted_at: nil)
        .includes(:user, posts: :uploads)
        .order(created_at: :desc)
        .limit(50)

      render json: {
        user: serialize_data(user, BasicUserSerializer),
        posts: serialize_data(topics, GuestSpotPostSerializer)
      }
    end

    def create
      category_id = CategoryHelper.public_feed_category_id
      raise Discourse::NotFound unless category_id

      # Auto-generate unique title
      title = "@#{current_user.username} - #{Time.now.to_i}"

      # Create topic with first post containing caption and images
      topic_creator = TopicCreator.new(
        current_user,
        Guardian.new(current_user),
        category: category_id,
        title: title,
        raw: params[:caption] || "",
        skip_validations: false
      )

      begin
        topic = topic_creator.create

        # TODO: Handle image uploads - need to associate uploads with the post
        # This will require upload_ids or using the composer's upload system

        render_serialized(topic, GuestSpotPostSerializer)
      rescue => e
        render_json_error(e.message)
      end
    end

    def update
      raise Discourse::InvalidAccess if !can_edit?(@topic)

      # Handle caption changes
      if params.key?(:caption)
        first_post = @topic.first_post
        revisor = PostRevisor.new(first_post, @topic)

        changes = { raw: params[:caption] }

        if !revisor.revise!(current_user, changes)
          render_json_error(@topic.errors.full_messages.join(", "))
          return
        end
      end

      # Handle pinning separately
      if params.key?(:pinned)
        # Convert to boolean (handles string "true"/"false" from params)
        should_pin = ActiveModel::Type::Boolean.new.cast(params[:pinned])

        if should_pin
          # Unpin any other posts by this user first (1 pin per artist)
          category_id = CategoryHelper.public_feed_category_id
          Topic
            .where(category_id: category_id, user_id: current_user.id)
            .where.not(id: @topic.id)
            .where.not(pinned_at: nil)
            .each { |topic| topic.update_pinned(false, false) }

          # Pin this post
          @topic.update_pinned(true, false) # true = pinned, false = not globally
        else
          # Unpin this post
          @topic.update_pinned(false, false)
        end
      end

      render_serialized(@topic, GuestSpotPostSerializer)
    end

    def destroy
      raise Discourse::InvalidAccess unless can_edit?(@topic)

      PostDestroyer.new(current_user, @topic.first_post).destroy
      render json: success_json
    end

    private

    def find_topic
      @topic = Topic.find(params[:id])

      # Verify it's in the Public Feed category
      category_id = CategoryHelper.public_feed_category_id
      unless @topic.category_id == category_id
        raise Discourse::NotFound
      end
    rescue ActiveRecord::RecordNotFound
      raise Discourse::NotFound
    end

    def can_edit?(topic)
      return false unless current_user
      topic.user_id == current_user.id || current_user.staff?
    end
  end
end
