# frozen_string_literal: true

# name: discourse-guest-spot
# about: Instagram-style public showcase with invite-only private forum for tattoo artists
# version: 20251024
# authors: Jake Goldsborough
# url: https://github.com/ducks/discourse-guest-spot

enabled_site_setting :guest_spot_enabled

register_asset "stylesheets/guest-spot.scss"

after_initialize do
  # Load helpers and serializers
  require_relative 'lib/guest_spot/category_helper'
  require_relative 'app/serializers/guest_spot_post_serializer'
  require_relative 'app/controllers/guest_spot/posts_controller'
  require_relative 'app/controllers/guest_spot/feed_controller'

  # Routes
  Discourse::Application.routes.append do
    scope module: :guest_spot do
      get '/guest-spot' => 'feed#index'
      get '/guest-spot/user/:username' => 'posts#by_user'
      resources :posts, only: [:index, :show, :create, :update, :destroy], path: '/guest-spot/posts'
    end
  end
end
