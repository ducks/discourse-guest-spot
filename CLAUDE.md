# CLAUDE.md - Development Guide

## Project Overview

The Guest Spot is a Discourse plugin that creates a public Instagram-style feed for artists while maintaining a private invite-only forum for industry discussion. The key architectural decision is to leverage Discourse's native features (Topics, Categories, Permissions) rather than building custom systems.

## Core Architecture Decisions

### Use Native Discourse Features

**Topics as Posts:** Instead of a custom `guest_spot_posts` table, we use Discourse Topics in a special "Public Feed" category. This gives us:
- Built-in commenting system
- Native permissions and moderation
- Existing image upload/S3 integration
- Discourse's trust levels and spam protection
- No custom database tables to maintain

**Categories for Access Control:** Public Feed and Private Forum use separate categories with different permission levels via Discourse groups.

**Composer for Creation:** New posts use Discourse's native composer with customizations (hidden title field, auto-generated titles).

## File Structure

```
discourse-guest-spot/
├── plugin.rb                    # Main plugin configuration
├── app/
│   ├── controllers/
│   │   └── guest_spot/
│   │       └── posts_controller.rb
│   └── serializers/
│       └── guest_spot_post_serializer.rb
├── assets/
│   ├── javascripts/discourse/
│   │   ├── routes/              # Ember route handlers
│   │   ├── templates/           # Handlebars/GJS templates
│   │   ├── components/          # Reusable components
│   │   ├── initializers/        # Plugin initialization code
│   │   └── discourse-guest-spot-route-map.js
│   └── stylesheets/
│       └── guest-spot.scss
├── config/
│   └── locales/
│       ├── client.en.yml        # Frontend translations
│       └── server.en.yml        # Backend translations
├── lib/
│   └── guest_spot/
│       └── category_helper.rb   # Shared helpers
└── scripts/
    └── create-test-data.rb      # Development utilities
```

## Code Patterns

### Backend (Ruby)

**CategoryHelper Pattern:**
Use helper modules for shared functionality:

```ruby
module GuestSpot
  module CategoryHelper
    def self.public_feed_category
      @public_feed_category ||= Category.find_by(slug: CATEGORY_SLUG) || 
                                create_public_feed_category
    end
  end
end
```

**Controllers:**
Keep controllers thin, delegate to Discourse's existing systems:

```ruby
def create
  category_id = CategoryHelper.public_feed_category_id
  title = "@#{current_user.username} - #{Time.now.to_i}"
  
  topic_creator = TopicCreator.new(
    current_user,
    Guardian.new(current_user),
    category: category_id,
    title: title,
    raw: params[:caption] || ""
  )
  
  topic = topic_creator.create
  render_serialized(topic, GuestSpotPostSerializer)
end
```

**Serializers:**
Transform Discourse models into JSON for the frontend:

```ruby
class GuestSpotPostSerializer < ApplicationSerializer
  attributes :id, :user_id, :username, :caption, :image_urls, :created_at, :pinned
  
  def caption
    object.first_post&.raw || ""
  end
  
  def image_urls
    object.first_post.uploads.map { |upload| UrlHelper.absolute(upload.url) }
  end
end
```

### Frontend (Ember.js)

**Route Map:**
Register all custom routes in `discourse-guest-spot-route-map.js`:

```javascript
export default function () {
  this.route("guest-spot-feed", { path: "/guest-spot" });
  this.route("guest-spot-post", { path: "/guest-spot/post/:id" });
  this.route("guest-spot-user", { path: "/guest-spot/user/:username" });
}
```

**Modern Component Patterns:**
Use GJS (Glimmer JavaScript) components with modern patterns:

```javascript
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";

export default class GuestSpotFeed extends Component {
  @service composer;
  @service currentUser;
  
  get canCreatePost() {
    return this.currentUser;
  }
  
  @action
  async createNewPost() {
    // Implementation
  }
}
```

**Initializers:**
Use initializers for plugin setup and event listeners:

```javascript
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "my-initializer",
  
  initialize(container) {
    withPluginApi("1.14.0", (api) => {
      // Plugin initialization code
    });
  },
};
```

**Avoid Deprecated APIs:**
- Use `registerValueTransformer` instead of `decorateWidget`
- Use modern component patterns instead of widgets
- Use `withPluginApi` version checks for compatibility

### Composer Customization

**Auto-generated Titles:**
Generate unique titles server-side and client-side using the same format:

```ruby
# Backend
title = "@#{current_user.username} - #{Time.now.to_i}"

# Frontend
const title = `@${this.currentUser.username} - ${Math.floor(Date.now() / 1000)}`;
```

**Hide Title Field:**
Use observers to hide the title input for Public Feed posts:

```javascript
const composer = container.lookup("service:composer");

const hideTitleField = () => {
  schedule("afterRender", () => {
    const model = composer.model;
    if (!model) return;
    
    const publicFeedCategory = model.site.categories.find(
      (c) => c.slug === "public-feed"
    );
    
    if (model.categoryId === publicFeedCategory?.id) {
      const titleInput = document.querySelector("#reply-control .title-input");
      if (titleInput) {
        titleInput.style.display = "none";
      }
    }
  });
};

composer.addObserver("model.categoryId", hideTitleField);
```

### Post-Creation Redirect

**Listen to Discourse Events:**
Use `appEvents` to hook into Discourse's lifecycle:

```javascript
const appEvents = container.lookup("service:app-events");
const router = container.lookup("service:router");

appEvents.on("topic:created", (createdPost, composerModel) => {
  const category = site.categories.find((c) => c.slug === "public-feed");
  
  if (composerModel.categoryId === category?.id) {
    next(() => {
      router.transitionTo("guest-spot-post", createdPost.topic_id);
    });
  }
});
```

## Development Workflow

### Local Setup

1. Clone Discourse and this plugin
2. Symlink plugin to Discourse plugins directory
3. Run Discourse development servers (Rails + Ember CLI)
4. Create test data: `rails runner plugins/discourse-guest-spot/scripts/create-test-data.rb`

### Creating Test Data

The test script disables rate limiting and uses `TopicCreator`:

```ruby
RateLimiter.disable

category = GuestSpot::CategoryHelper.public_feed_category

topic_creator = TopicCreator.new(
  user,
  Guardian.new(user),
  category: category.id,
  title: title,
  raw: caption,
  skip_validations: false
)

topic = topic_creator.create
```

### Common Tasks

**Add a new route:**
1. Add to `discourse-guest-spot-route-map.js`
2. Create route file in `routes/`
3. Create template file in `templates/`
4. Add controller if needed

**Add a new API endpoint:**
1. Add route to `plugin.rb`
2. Create controller action
3. Create serializer if returning data
4. Add translation keys to `config/locales/`

**Customize composer behavior:**
1. Create initializer in `initializers/`
2. Use `withPluginApi` and container.lookup for services
3. Use observers for reactive behavior
4. Schedule DOM manipulation with `afterRender`

## Testing Strategy

**Manual Testing:**
- Create test data with the script
- Test all user flows in browser
- Verify responsive design
- Check permissions and access control

**Future: Automated Tests:**
- Controller specs for API endpoints
- Serializer specs for JSON output
- Component tests for frontend behavior
- Integration tests for full flows

## Discourse-Specific Knowledge

### TopicCreator
Use `TopicCreator` instead of `Topic.create` for proper validation and callbacks:

```ruby
TopicCreator.new(user, guardian, options).create
```

### Guardian
Always use Guardian for permission checks:

```ruby
Guardian.new(current_user).can_create_topic?(category)
```

### Image Uploads
Discourse handles uploads automatically. Access via:

```ruby
topic.first_post.uploads  # Returns array of Upload objects
upload.url               # Relative URL
UrlHelper.absolute(upload.url)  # Absolute URL
```

### Categories
Create categories with proper permissions:

```ruby
Category.create!(
  name: "Public Feed",
  user_id: Discourse.system_user.id,
  permissions: {
    everyone: :readonly,
    invited_artists: :full
  }
)
```

## Conventions

### Naming
- Ruby: `snake_case` for files, methods, variables
- JavaScript: `camelCase` for variables, `PascalCase` for components
- Routes: `kebab-case` for URLs
- CSS: `kebab-case` for classes

### Translation Keys
- Namespace under `guest_spot`
- Use `client.en.yml` for frontend strings
- Use `server.en.yml` for backend strings
- Format: `guest_spot.section.key`

### Code Style
- No emoji in code or documentation
- Prefer native Discourse features over custom code
- Use modern APIs, check for deprecation warnings
- Keep components small and focused
- Avoid jQuery, use native DOM APIs or Ember helpers

## Resources

- [Discourse Plugin Basics](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins-part-1/30515)
- [Discourse API Docs](https://docs.discourse.org/)
- [Ember.js Guides](https://guides.emberjs.com/)
- Plugin examples: discourse-solved, discourse-voting, discourse-chat

## Notes

This plugin prioritizes integration with Discourse over creating parallel systems. When adding features, always check if Discourse already provides the functionality before building custom solutions.
