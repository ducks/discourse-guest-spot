# frozen_string_literal: true

# name: discourse-guest-spot
# about: Instagram-style public showcase with invite-only private forum for tattoo artists
# version: 20251024
# authors: Jake Goldsborough
# url: https://github.com/ducks/discourse-guest-spot

enabled_site_setting :guest_spot_enabled

register_asset "stylesheets/guest-spot.scss"

after_initialize do
  # Load helpers
  require_relative 'lib/guest_spot/category_helper'
end
