# frozen_string_literal: true

class GuestSpotPost < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :image_urls, presence: true
  validate :at_least_one_image

  # Pinning logic
  before_save :unpin_other_posts, if: :will_save_change_to_pinned?

  scope :pinned, -> { where(pinned: true).order(created_at: :desc) }
  scope :recent, -> { where(pinned: false).order(created_at: :desc) }

  def can_edit?(current_user)
    return false unless current_user
    user_id == current_user.id || current_user.staff?
  end

  def pin!
    update!(pinned: true)
  end

  def unpin!
    update!(pinned: false)
  end

  private

  def at_least_one_image
    if image_urls.blank? || image_urls.empty?
      errors.add(:image_urls, "must have at least one image")
    end
  end

  def unpin_other_posts
    if pinned? && pinned_changed?
      # Only allow one pinned post per user
      GuestSpotPost.where(user_id: user_id, pinned: true)
                   .where.not(id: id)
                   .update_all(pinned: false)
    end
  end
end
