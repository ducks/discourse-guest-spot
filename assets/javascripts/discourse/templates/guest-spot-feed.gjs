import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import GuestSpotPostCard from "../components/guest-spot-post-card";
import { i18n } from "discourse-i18n";

export default class GuestSpotFeed extends Component {
  @service composer;
  @service currentUser;
  @service siteSettings;

  get canCreatePost() {
    return this.currentUser;
  }

  @action
  async createNewPost() {
    // Get the Public Feed category ID
    const response = await fetch('/categories.json');
    const data = await response.json();
    const publicFeedCategory = data.category_list.categories.find(
      cat => cat.slug === 'public-feed'
    );

    if (!publicFeedCategory) {
      // eslint-disable-next-line no-console
      console.error('Public Feed category not found');
      return;
    }

    // Auto-generate title (same format as backend)
    const title = `@${this.currentUser.username} - ${Math.floor(Date.now() / 1000)}`;

    this.composer.open({
      action: "createTopic",
      draftKey: `new_topic_${publicFeedCategory.id}`,
      categoryId: publicFeedCategory.id,
      topicTitle: title,
    });
  }

  <template>
    <div class="guest-spot-feed">
      <div class="feed-header">
        <h1>{{i18n "guest_spot.feed.title"}}</h1>
        {{#if this.canCreatePost}}
          <DButton
            @action={{this.createNewPost}}
            @label="guest_spot.feed.new_post"
            @icon="plus"
            class="btn-primary new-post-btn"
          />
        {{/if}}
      </div>

      {{#if @model.pinned.length}}
        <div class="pinned-section">
          <h2>{{i18n "guest_spot.feed.pinned"}}</h2>
          <div class="pinned-carousel">
            {{#each @model.pinned as |post|}}
              <GuestSpotPostCard @post={{post}} />
            {{/each}}
          </div>
        </div>
      {{/if}}

      <div class="recent-section">
        <h2>{{i18n "guest_spot.feed.recent"}}</h2>
        {{#if @model.posts.length}}
          <div class="posts-grid">
            {{#each @model.posts as |post|}}
              <GuestSpotPostCard @post={{post}} />
            {{/each}}
          </div>
        {{else}}
          <p class="no-posts">{{i18n "guest_spot.feed.no_posts"}}</p>
        {{/if}}
      </div>
    </div>
  </template>
}
