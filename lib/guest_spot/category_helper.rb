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
      category = Category.create!(
        name: CATEGORY_NAME,
        slug: CATEGORY_SLUG,
        user_id: Discourse.system_user.id,
        color: "0088CC",
        text_color: "FFFFFF",
        description: "Public showcase of artist work. Publicly viewable, posting restricted to approved artists.",
        read_restricted: false  # Makes category publicly viewable even if site requires login
      )

      # Set permissions: Everyone can see, only trust_level_1+ can create/reply
      category.set_permissions(
        everyone: :readonly,
        trust_level_1: :full
      )
      category.save!

      category
    end
  end
end
