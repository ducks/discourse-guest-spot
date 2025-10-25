import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";

export default class GuestSpotPost extends Component {
  <template>
    <div class="guest-spot-post-detail">
      <div class="post-header">
        <LinkTo @route="guest-spot-feed" class="back-link">
          ← {{i18n "guest_spot.post.back_to_feed"}}
        </LinkTo>
      </div>

      <div class="post-content">
        <div class="post-images">
          {{#each @model.guest_spot_post.image_urls as |imageUrl|}}
            <img src={{imageUrl}} alt={{@model.guest_spot_post.caption}} class="post-image" />
          {{/each}}
        </div>

        <div class="post-info">
          <div class="post-author">
            {{avatar @model.guest_spot_post.user imageSize="large"}}
            <div class="author-details">
              <h2 class="username">{{@model.guest_spot_post.user.username}}</h2>
              {{#if @model.guest_spot_post.pinned}}
                <span class="pinned-badge">Featured</span>
              {{/if}}
            </div>
          </div>

          {{#if @model.guest_spot_post.caption}}
            <p class="post-caption">{{@model.guest_spot_post.caption}}</p>
          {{/if}}

          <div class="post-meta">
            <span class="post-date">{{@model.guest_spot_post.created_at}}</span>
          </div>
        </div>
      </div>
    </div>
  </template>
}
