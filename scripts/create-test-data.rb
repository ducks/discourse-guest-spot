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
users.each_with_index do |user, user_index|
  # Create 2-4 regular posts per user
  num_posts = rand(2..4)

  num_posts.times do |i|
    caption = captions.sample
    # Use unsplash placeholder with unique seed
    image_seed = (user_index * 100) + i
    image_url = "https://picsum.photos/seed/#{image_seed}/600/600"

    # Include image in post content using markdown
    raw_content = "![tattoo](#{image_url})\n\n#{caption}"

    # Use first 20 chars of caption as title, add counter if title exists
    title = caption[0...20].strip
    counter = 1
    original_title = title
    while Topic.where(category_id: category.id, title: title).exists?
      title = "#{original_title} #{counter}"
      counter += 1
    end

    post_creator = PostCreator.new(
      user,
      category: category.id,
      title: title,
      raw: raw_content
    )

    post = post_creator.create
    topic = post.topic
    if topic.errors.any?
      puts "  ERROR creating topic: #{topic.errors.full_messages.join(', ')}"
    else
      puts "  Created topic #{topic.id} for #{user.username}"
    end
  end

  # Create 1 pinned post per user
  featured_caption = "✨ Featured work - #{captions.sample}"
  image_seed = (user_index * 100) + 999
  image_url = "https://picsum.photos/seed/#{image_seed}/600/600"
  raw_content = "![tattoo](#{image_url})\n\n#{featured_caption}"

  # Use first 20 chars of caption as title, add counter if title exists
  title = featured_caption[0...20].strip
  counter = 1
  original_title = title
  while Topic.where(category_id: category.id, title: title).exists?
    title = "#{original_title} #{counter}"
    counter += 1
  end

  post_creator = PostCreator.new(
    user,
    category: category.id,
    title: title,
    raw: raw_content
  )

  post = post_creator.create
  topic = post.topic
  if topic.errors.any?
    puts "  ERROR creating pinned topic: #{topic.errors.full_messages.join(', ')}"
  else
    topic.update_pinned(true, false) # Pin to category (not global)
    puts "  Created PINNED topic #{topic.id} for #{user.username}"
  end
end

total_topics = Topic.where(category_id: category.id).count
pinned_count = Topic.where(category_id: category.id).where.not(pinned_at: nil).count

puts "\n✅ Done!"
puts "Total users: #{users.count}"
puts "Total topics: #{total_topics}"
puts "Pinned topics: #{pinned_count}"
puts "\nVisit http://localhost:4200/c/public-feed to see the showcase!"
puts "\nNote: Images are from picsum.photos (Lorem Picsum placeholder service)"
