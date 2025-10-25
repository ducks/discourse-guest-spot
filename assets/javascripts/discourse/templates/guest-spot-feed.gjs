import Component from "@glimmer/component";
import GuestSpotPostCard from "../components/guest-spot-post-card";
import { i18n } from "discourse-i18n";

export default class GuestSpotFeed extends Component {
  <template>
    <div class="guest-spot-feed">
      <h1>{{i18n "guest_spot.feed.title"}}</h1>

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
