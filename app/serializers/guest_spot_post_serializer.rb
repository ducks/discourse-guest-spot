# frozen_string_literal: true

class GuestSpotPostSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :caption,
             :image_urls,
             :pinned,
             :comments_enabled,
             :comments_locked,
             :created_at,
             :updated_at

  has_one :user, serializer: BasicUserSerializer, embed: :objects

  def user
    object.user
  end
end
