# frozen_string_literal: true

class CreateGuestSpotPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :guest_spot_posts do |t|
      t.integer :user_id, null: false
      t.text :caption
      t.string :image_urls, array: true, default: []
      t.boolean :pinned, default: false
      t.boolean :comments_enabled, default: true
      t.boolean :comments_locked, default: false
      t.timestamps
    end

    add_index :guest_spot_posts, :user_id
    add_index :guest_spot_posts, :pinned
    add_index :guest_spot_posts, :created_at
  end
end
