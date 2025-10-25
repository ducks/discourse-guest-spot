# frozen_string_literal: true

# Run with: bundle exec rails runner plugins/discourse-guest-spot/scripts/create-test-data.rb

puts "Creating test users and posts for The Guest Spot..."

# Sample tattoo-related usernames
usernames = ["ink_master_jay", "needle_queen", "flash_artist_sam", "tattoo_mike", "rose_ink"]

# Sample image URLs (placeholder tattoo images)
sample_images = [
  "https://picsum.photos/seed/tattoo1/800/800",
  "https://picsum.photos/seed/tattoo2/800/800",
  "https://picsum.photos/seed/tattoo3/800/800",
  "https://picsum.photos/seed/tattoo4/800/800",
  "https://picsum.photos/seed/tattoo5/800/800",
  "https://picsum.photos/seed/tattoo6/800/800",
  "https://picsum.photos/seed/tattoo7/800/800",
  "https://picsum.photos/seed/tattoo8/800/800",
]

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

puts "\nCreating posts..."

# Create posts for each user
users.each do |user|
  # Create 2-4 regular posts per user
  num_posts = rand(2..4)

  num_posts.times do |i|
    post = GuestSpotPost.create!(
      user: user,
      caption: captions.sample,
      image_urls: [sample_images.sample],
      comments_enabled: true,
      pinned: false
    )
    puts "  Created post #{post.id} for #{user.username}"
  end

  # Create 1 pinned post per user
  pinned_post = GuestSpotPost.create!(
    user: user,
    caption: "✨ Featured work - #{captions.sample}",
    image_urls: [sample_images.sample],
    comments_enabled: true,
    pinned: true
  )
  puts "  Created PINNED post #{pinned_post.id} for #{user.username}"
end

total_posts = GuestSpotPost.count
pinned_count = GuestSpotPost.pinned.count

puts "\n✅ Done!"
puts "Total users: #{users.count}"
puts "Total posts: #{total_posts}"
puts "Pinned posts: #{pinned_count}"
puts "\nVisit http://localhost:4200/ to see the feed!"
