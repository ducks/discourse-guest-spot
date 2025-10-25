# frozen_string_literal: true

module GuestSpot
  module CategoryHelper
    CATEGORY_NAME = "Public Feed"
    CATEGORY_SLUG = "public-feed"

    def self.public_feed_category
      @public_feed_category ||= Category.find_by(slug: CATEGORY_SLUG) ||
                                create_public_feed_category
    end

    def self.public_feed_category_id
      public_feed_category&.id
    end

    private

    def self.create_public_feed_category
      Category.create!(
        name: CATEGORY_NAME,
        slug: CATEGORY_SLUG,
        user_id: Discourse.system_user.id,
        color: "0088CC",
        text_color: "FFFFFF",
        description: "Public feed of artist work. Posts here appear on the guest spot feed."
      )
    end
  end
end
