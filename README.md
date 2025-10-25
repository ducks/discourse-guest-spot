# The Guest Spot

A Discourse plugin that transforms your forum into a dual-purpose platform for tattoo artists: a public Instagram-style showcase combined with a private, invite-only community.

## What is The Guest Spot?

**Public side:** Artists share their work in a beautiful feed with portfolio pages. Anyone can view and engage.

**Private side:** Invite-only forum for shop talk, technique sharing, and industry discussions.

The name comes from tattoo culture - a "guest spot" is when a traveling artist works at another shop. It captures the collaborative, welcoming spirit we're building here.

## Status

🚧 **Alpha Development** - Basic functionality working. Core features implemented, advanced features in progress.

See [DESIGN.md](DESIGN.md) for the complete design document and [TODO.md](TODO.md) for current development status.

## Current Features

### ✅ Implemented
- **Public feed** at `/guest-spot` with grid layout
- **Post creation** using Discourse's native composer with auto-generated titles
- **Artist profiles** at `/guest-spot/user/:username` showing all their posts
- **Individual post pages** at `/guest-spot/post/:id`
- **Native Discourse Topics** as the data layer (leverages existing features)

### 🚧 In Progress
- Pinned posts with carousel UI
- Comment management controls
- Multiple images per post

### 📋 Planned
- **Invite tree system** (lobste.rs style) for quality curation
- **Artist controls** - pin posts, manage comments, mute users
- **Community moderation** - voting on comments, auto-hide threshold
- **Private forum** completely separate from public profiles

## Architecture

This plugin takes a **Discourse-native approach**:
- Uses Discourse Topics (in a special "Public Feed" category) instead of custom database tables
- Leverages Discourse's built-in commenting, permissions, and moderation tools
- Extends Discourse's composer and routing for a custom UI
- Reuses Discourse's image upload and S3 integration

This approach means:
- Less custom code to maintain
- Better integration with existing Discourse features
- Familiar admin controls for site operators
- Easier to extend and customize

## Installation

1. Add to your `app.yml`:
```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/ducks/discourse-guest-spot.git
```

2. Rebuild your container:
```bash
./launcher rebuild app
```

3. Create test data (optional):
```bash
./launcher enter app
cd /var/www/discourse/plugins/discourse-guest-spot
rails runner scripts/create-test-data.rb
```

## Development

The plugin follows standard Discourse plugin structure:

- `plugin.rb` - Main plugin configuration
- `app/` - Rails backend (controllers, models, serializers)
- `assets/javascripts/discourse/` - Ember.js frontend (routes, templates, components)
- `config/locales/` - Translation strings
- `lib/` - Shared Ruby code and helpers

See [CLAUDE.md](CLAUDE.md) for coding patterns and conventions used in this project.
