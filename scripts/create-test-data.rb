# frozen_string_literal: true

# Run with: bundle exec rails runner plugins/discourse-guest-spot/scripts/create-test-data.rb

puts "Creating test users and posts for The Guest Spot..."

# Sample tattoo-related usernames
usernames = ["ink_master_jay", "needle_queen", "flash_artist_sam", "tattoo_mike", "rose_ink"]

# Sample captions
captions = [
  "Fresh geometric piece from today's session 🖤",
  "Traditional rose, always a classic",
  "Custom sleeve work in progress",
  "Fine line mandala - 8 hours but worth it",
  "Black and grey realism portrait",
  "Japanese-inspired dragon back piece",
  "Minimal line work on forearm",
  "Dotwork stippling technique",
  "Watercolor style flowers",
  "Neo-traditional skull and roses",
]

users = []

# Create or find users
usernames.each_with_index do |username, i|
  user = User.find_by(username: username)

  if user
    puts "Found existing user: #{username}"
  else
    user = User.create!(
      username: username,
      email: "#{username}@example.com",
      password: "TestPass123!@#",
      approved: true,
      active: true,
      trust_level: 2
    )
    puts "Created user: #{username}"
  end

  users << user
end

# Get or create Public Feed category
require_relative '../lib/guest_spot/category_helper'
category = GuestSpot::CategoryHelper.public_feed_category
puts "\nUsing category: #{category.name} (id: #{category.id})"

puts "\nCreating posts..."

# Disable rate limiting for seed data
RateLimiter.disable

# Create posts for each user
users.each do |user|
  # Create 2-4 regular posts per user
  num_posts = rand(2..4)

  num_posts.times do |i|
    title = "@#{user.username} - #{Time.now.to_i + i}"

    topic_creator = TopicCreator.new(
      user,
      Guardian.new(user),
      category: category.id,
      title: title,
      raw: captions.sample,
      skip_validations: false
    )

    topic = topic_creator.create
    puts "  Created topic #{topic.id} for #{user.username}"
  end

  # Create 1 pinned post per user
  title = "@#{user.username} - #{Time.now.to_i + 100}"

  topic_creator = TopicCreator.new(
    user,
    Guardian.new(user),
    category: category.id,
    title: title,
    raw: "✨ Featured work - #{captions.sample}",
    skip_validations: false
  )

  topic = topic_creator.create
  topic.update_pinned(true, false) # Pin to category (not global)
  puts "  Created PINNED topic #{topic.id} for #{user.username}"
end

total_topics = Topic.where(category_id: category.id).count
pinned_count = Topic.where(category_id: category.id).where.not(pinned_at: nil).count

puts "\n✅ Done!"
puts "Total users: #{users.count}"
puts "Total topics: #{total_topics}"
puts "Pinned topics: #{pinned_count}"
puts "\nVisit http://localhost:4200/guest-spot to see the feed!"
puts "\nNote: Topics created without images. To add images, upload them via the Discourse UI."
