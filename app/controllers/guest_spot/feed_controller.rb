# frozen_string_literal: true

module GuestSpot
  class FeedController < ::ApplicationController
    requires_plugin 'discourse-guest-spot'

    def index
      # Just render the Ember app
    end
  end
end
