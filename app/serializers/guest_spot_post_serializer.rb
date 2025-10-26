# frozen_string_literal: true

class GuestSpotPostSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :caption,
             :image_urls,
             :pinned,
             :visible,
             :comments_enabled,
             :comments_locked,
             :created_at,
             :updated_at

  has_one :user, serializer: BasicUserSerializer, embed: :objects

  def id
    object.id
  end

  def user_id
    object.user_id
  end

  def user
    object.user
  end

  def caption
    object.first_post&.raw || ""
  end

  def image_urls
    return [] unless object.first_post

    object.first_post.uploads.map do |upload|
      UrlHelper.absolute(upload.url)
    end
  end

  def pinned
    object.pinned_at.present?
  end

  def visible
    object.visible
  end

  def comments_enabled
    !object.closed
  end

  def comments_locked
    object.closed
  end

  def created_at
    object.created_at
  end

  def updated_at
    object.updated_at
  end
end
