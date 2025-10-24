# The Guest Spot - Design Document

## Project Vision

The Guest Spot is a dual-purpose platform for tattoo artists:
- **Public showcase**: Instagram-style feed where artists display their work to the world
- **Private community**: Invite-only forum for shop talk, technique sharing, and industry discussions

The name "Guest Spot" comes from tattoo industry terminology - when a traveling artist works at another shop temporarily. It captures the collaborative, welcoming spirit while maintaining quality through curation.

## Core Principles

1. **Quality through curation**: Invite-only with public invite tree (lobste.rs model)
2. **Artist ownership**: Artists control their content and discussions around it
3. **Community moderation**: Balance between artist control and community standards
4. **Professional space**: Industry-focused, not another social media dopamine machine

## User Types

### Public Visitors
- Can view public feed and artist portfolios
- Can comment on public posts (subject to moderation)
- Can see that it's invite-only but not who has access
- Cannot access /forum

### Members (Invited Artists)
- Full access to public feed and private forum
- Can post to public feed with pinning/moderation controls
- Can invite others (with accountability via invite tree)
- Have portfolio pages showcasing their work

### Moderators
- Handle reports and edge cases
- Can see full invite tree
- Enforce community standards in private forum
- Review serious violations in public spaces

## Site Structure

### `/` - Public Feed (Homepage)

**Top Section: Pinned Carousel**
- Horizontal scrolling carousel
- Each artist can pin exactly 1 post
- Shows off "best work" from each artist
- Large images, full-screen optimized
- Artist name visible on each slide
- Click through to post detail or profile

**Main Section: Recent Grid**
- Masonry/grid layout (Instagram/Pinterest style)
- Chronological feed of all recent posts
- Excludes pinned posts (they only show in carousel)
- Infinite scroll
- Smaller thumbnails for browsing

**Post visibility:**
- When artist pins a post: moves from grid to carousel
- When artist unpins: returns to grid at original timestamp
- All posts visible in both feed and artist profiles

### `/forum` - Private Forum

**Access:**
- Invite-only, members only
- Traditional Discourse categories and topics
- Full forum functionality (PMs, notifications, trust levels)

**Categories (examples):**
- Technique & Process
- Business & Shop Management
- Equipment & Supplies
- Apprentice Discussions
- Regional meetups

**Moderation:**
- Traditional moderator enforcement
- Higher trust environment (invite tree creates accountability)
- Flags/reports go to moderators
- If someone's problematic, reflects on their inviter

**Complete separation from public:**
- Forum activity NEVER appears on public profiles
- Private discussions stay private
- No crossover between forum posts and public feed

### `/u/:username` - Artist Profile

**Components:**
- Profile header (bio, location, shop affiliation)
- Portfolio grid of all their public feed posts
- Stats (post count, member since, etc.)
- Currently pinned post indicator
- NO forum activity shown (complete separation)

**Privacy controls:**
- Can make entire profile members-only vs public
- Cannot toggle forum visibility (it's always separate)

### `/post/:id` - Individual Post

**Layout:**
- Full-size image(s) with gallery support
- Caption/description from artist
- Artist name with link to profile
- Posted date
- Comments section (if enabled by artist)

**Artist controls (on their own posts):**
- Pin/unpin (max 1 pinned at a time)
- Enable/disable comments
- Lock/unlock comments (prevents new, keeps existing)
- Mute specific users from commenting

**Community moderation:**
- Upvote/downvote on comments
- Net score of -3 auto-hides comment (expandable)
- Report button for serious violations
- Moderators can delete after review

## Invite System

### Invite Tree Model (lobste.rs style)

**Core mechanics:**
- Each member gets X invites (configurable, start with 3-5)
- Invite tree is publicly visible
- Shows: "UserA invited UserB who invited UserC"
- Creates accountability - if your invites cause problems, it reflects on you

**Invite requirements:**
- May require minimum trust level before getting invites
- Could track "invite quality" (do they stay and contribute?)
- Invites regenerate slowly over time (prevent hoarding)

**Public visibility:**
- Anyone can see the invite tree
- Shows community growth and connections
- Helps establish legitimacy and trust

### Initial Seed

How to bootstrap:
1. Core group of trusted artists get initial accounts (founding members)
2. Each gets 5 invites to start
3. They invite people they trust/respect
4. Growth is organic but controlled

## Moderation Model

### Two-Tier System

**Public Side (/ and profiles):**
- Lower trust (anyone can view/comment)
- Automated + artist controls
- Community voting on comments
- Artist muting for repeat offenders

**Private Side (/forum):**
- Higher trust (invite-only)
- Traditional moderator enforcement
- Invite tree creates social pressure
- Less automation needed

### Artist Controls (Public Posts)

**What artists CAN do:**
- Toggle comments on/off entirely
- Lock comments (no new ones, existing stay)
- Mute users from their posts (requires pattern: 3+ hidden comments)
- Pin one post to showcase

**What artists CANNOT do:**
- Delete individual comments (prevents silencing critique)
- Override community downvotes
- Change post timestamps

### Community Moderation (Comments)

**Voting system:**
- Upvote/downvote on comments
- Net score system (upvotes - downvotes)
- Net score of -3 auto-hides comment
- Hidden comments can be expanded (not deleted)
- Prevents both trolls AND artists from abuse

**Escalation path:**
1. Comment hits net -3 → auto-hidden
2. User accumulates 3+ hidden comments on artist's posts → artist can mute them
3. Comment gets reported → moderators review → can delete if truly abusive

**Report handling:**
- Report button available on all comments
- Goes to moderator queue
- Moderators can delete if violation of site rules
- Serious violations can result in account suspension

### Muting Requirements

To prevent abuse of muting:
- Artist can only mute users who have 3+ hidden comments on their posts
- OR users who have been reported X times site-wide
- Muting is account-to-account (all posts, not just one)
- Muted users can still see posts, just can't comment

## Technical Architecture

### Database Schema (Initial thoughts)

**New tables needed:**
- `guest_spot_posts` - Public feed posts
  - user_id, image_urls (array), caption, created_at, pinned (boolean)
- `guest_spot_comments` - Comments on posts
  - post_id, user_id, body, upvotes, downvotes, hidden (boolean)
- `guest_spot_invites` - Invite tree tracking
  - inviter_id, invitee_id, created_at, used (boolean)
- `guest_spot_mutes` - Artist muting
  - artist_id, muted_user_id, reason, created_at

**Leverage existing Discourse:**
- Users table (authentication, profiles)
- Categories (for private forum)
- Topics/Posts (for private forum)
- Trust levels
- Notifications system

### Image Handling

**Storage:**
- Use Discourse's existing upload system
- S3 integration for media
- Image optimization/thumbnails

**Gallery support:**
- Multiple images per post
- Swipeable galleries
- Optimized loading (thumbnails → full size)

## Open Questions

### Feed Algorithm

Should the public feed be:
- Purely chronological?
- Have any "hot" or "trending" sorting?
- Show different content to logged-in vs logged-out users?

**Current thinking:** Start purely chronological. Add sorting options later if needed.

### Portfolio vs Feed

Should artist profiles show:
- Only pinned post + recent work?
- All posts in chronological order?
- Posts organized by style/category?

**Current thinking:** All posts in grid, with pinned post highlighted at top.

### Comment Threading

Should comments on posts be:
- Flat list (like Instagram)?
- Threaded (like Reddit)?
- Hybrid (direct replies only)?

**Current thinking:** Start flat, add threading if requested.

### Mobile Experience

Should there be:
- Native apps?
- Progressive web app?
- Just responsive web?

**Current thinking:** Start responsive web, PWA if it takes off.

## Implementation Phases

### Phase 1: Core Feed (MVP)
- Public feed with grid layout
- Post creation (single image, caption)
- Artist profiles (basic)
- Individual post pages
- No comments yet, no pinning

### Phase 2: Engagement
- Comments on posts
- Upvote/downvote system
- Auto-hide at threshold
- Artist controls (comment toggle, lock)

### Phase 3: Showcase
- Pinned posts
- Carousel UI
- Multiple images per post
- Gallery viewer

### Phase 4: Moderation
- Muting system
- Report functionality
- Moderator dashboard
- Invite tree display

### Phase 5: Integration
- Private forum access
- Forum categories
- Notifications

## Success Metrics

How do we know it's working?

**Community health:**
- Retention rate of invited members
- Invite tree depth (organic growth)
- Ratio of constructive vs hidden comments
- Forum engagement levels

**Content quality:**
- Pinned posts represent best work
- Public feed attracts visitors
- Comments add value (not just "nice!")

**Artist satisfaction:**
- Artists use pinning feature
- Artists engage in private forum
- Artists invite peers they respect
- Low moderation overhead

## Future Considerations

Features that might come later:

**Follower system:**
- Follow specific artists
- Personalized feed of followed artists
- Notifications for new posts

**Collections/Albums:**
- Artists organize posts into series
- "Process" albums showing WIP
- Style-based collections

**Collaboration features:**
- Multi-artist posts (guest spots!)
- Shared projects
- Shop accounts vs individual artists

**Search/Discovery:**
- Tag system (styles, techniques)
- Search by artist, style, or content
- Featured collections by moderators

**Monetization:**
- Artist shop pages (prints, merch)
- Booking integration
- Premium memberships?

## Notes

- Keep it simple first - solve the core problem (showcase + private space)
- Don't over-engineer - let community needs guide features
- Artist ownership is key - they need to feel in control
- Quality curation via invites prevents it becoming another spam-filled social network
- Forum stays completely separate from public profiles - no crossover
