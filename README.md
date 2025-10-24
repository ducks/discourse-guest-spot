# The Guest Spot

A Discourse plugin that transforms your forum into a dual-purpose platform for tattoo artists: a public Instagram-style showcase combined with a private, invite-only community.

## What is The Guest Spot?

**Public side:** Artists share their work in a beautiful feed with portfolio pages. Anyone can view and engage.

**Private side:** Invite-only forum for shop talk, technique sharing, and industry discussions.

The name comes from tattoo culture - a "guest spot" is when a traveling artist works at another shop. It captures the collaborative, welcoming spirit we're building here.

## Status

🚧 **Early Design Phase** - Currently documenting requirements and planning architecture. Not ready for installation yet.

See [DESIGN.md](DESIGN.md) for the complete design document.

## Key Features (Planned)

- **Public feed** with pinned carousel and recent grid
- **Artist portfolios** showcasing their best work
- **Invite tree system** (lobste.rs style) for quality curation
- **Artist controls** - pin posts, manage comments, mute users
- **Community moderation** - voting on comments, auto-hide threshold
- **Private forum** completely separate from public profiles

## Tech Stack

- Discourse plugin (Ruby + Ember.js)
- Leverages existing Discourse authentication and permissions
- New database tables for posts, comments, invites
- Uses Discourse's existing image upload/S3 integration

## Development Roadmap

### Phase 1: Core Feed (MVP)
- Public feed with grid layout
- Post creation
- Artist profiles
- Individual post pages

### Phase 2: Engagement
- Comments with voting
- Artist controls
- Auto-hide system

### Phase 3: Showcase
- Pinned posts with carousel
- Multiple images per post
- Gallery viewer

### Phase 4: Moderation
- Muting system
- Reports
- Invite tree display

### Phase 5: Integration
- Private forum access
- Full permissions integration
