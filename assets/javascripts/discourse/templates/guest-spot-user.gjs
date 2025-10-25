import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import GuestSpotPostCard from "../components/guest-spot-post-card";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";

export default class GuestSpotUser extends Component {
  <template>
    <div class="guest-spot-feed">
      <div class="user-profile-header">
        <LinkTo @route="guest-spot-feed" class="back-link">
          ← {{i18n "guest_spot.user.back"}}
        </LinkTo>

        <div class="user-info">
          {{avatar @model.user imageSize="huge"}}
          <h1>{{@model.user.username}}</h1>
        </div>
      </div>

      <div class="user-posts-section">
        <h2>{{i18n "guest_spot.user.posts"}}</h2>
        {{#if @model.posts.length}}
          <div class="posts-grid">
            {{#each @model.posts as |post|}}
              <GuestSpotPostCard @post={{post}} @hideAuthor={{true}} />
            {{/each}}
          </div>
        {{else}}
          <p class="no-posts">{{i18n "guest_spot.user.no_posts"}}</p>
        {{/if}}
      </div>
    </div>
  </template>
}
