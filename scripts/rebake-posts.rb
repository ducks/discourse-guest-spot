# frozen_string_literal: true

# Rebake all posts in Public Feed category to extract image URLs
category = Category.find_by(slug: 'public-feed')
posts = Post.joins(:topic).where(topics: { category_id: category.id })

puts "Rebaking #{posts.count} posts..."
posts.each do |post|
  post.rebake!
end

puts "\nDone! Checking topics..."
Topic.where(category_id: category.id).limit(5).each do |topic|
  puts "Topic #{topic.id}: image_url = #{topic.image_url.inspect}"
end
