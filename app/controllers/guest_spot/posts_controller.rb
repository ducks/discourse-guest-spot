# frozen_string_literal: true

module GuestSpot
  class PostsController < ::ApplicationController
    requires_plugin 'discourse-guest-spot'

    before_action :ensure_logged_in, only: [:create, :update, :destroy]
    before_action :find_post, only: [:show, :update, :destroy]

    def index
      posts = GuestSpotPost.includes(:user).order(created_at: :desc).limit(50)

      render json: {
        posts: serialize_data(posts, GuestSpotPostSerializer),
        pinned: serialize_data(GuestSpotPost.pinned.includes(:user), GuestSpotPostSerializer)
      }
    end

    def show
      render_serialized(@post, GuestSpotPostSerializer)
    end

    def by_user
      user = User.find_by(username_lower: params[:username].downcase)
      raise Discourse::NotFound unless user

      posts = GuestSpotPost
        .where(user: user)
        .includes(:user)
        .order(created_at: :desc)
        .limit(50)

      render json: {
        user: serialize_data(user, BasicUserSerializer),
        posts: serialize_data(posts, GuestSpotPostSerializer)
      }
    end

    def create
      post = GuestSpotPost.new(post_params)
      post.user = current_user

      if post.save
        render_serialized(post, GuestSpotPostSerializer)
      else
        render_json_error(post.errors.full_messages.join(", "))
      end
    end

    def update
      raise Discourse::InvalidAccess unless @post.can_edit?(current_user)

      if @post.update(post_params)
        render_serialized(@post, GuestSpotPostSerializer)
      else
        render_json_error(@post.errors.full_messages.join(", "))
      end
    end

    def destroy
      raise Discourse::InvalidAccess unless @post.can_edit?(current_user)

      @post.destroy!
      render json: success_json
    end

    private

    def find_post
      @post = GuestSpotPost.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Discourse::NotFound
    end

    def post_params
      params.permit(:caption, :pinned, :comments_enabled, :comments_locked, image_urls: [])
    end
  end
end
