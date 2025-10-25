import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { on } from "@ember/modifier";
import { not } from "truth-helpers";
import avatar from "discourse/helpers/avatar";

export default class GuestSpotPostCard extends Component {
  get firstImage() {
    return this.args.post.image_urls?.[0];
  }

  stopPropagation = (event) => {
    event.stopPropagation();
  };

  <template>
    <LinkTo @route="guest-spot-post" @model={{@post.id}} class="guest-spot-post-card">
      {{#if this.firstImage}}
        <img src={{this.firstImage}} alt={{@post.caption}} class="post-image" />
      {{/if}}

      <div class="post-meta">
        {{#if (not @hideAuthor)}}
          <div class="post-author">
            {{avatar @post.user imageSize="small"}}
            <LinkTo
              @route="guest-spot-user"
              @model={{@post.user.username}}
              class="username-link"
              {{on "click" this.stopPropagation}}
            >
              {{@post.user.username}}
            </LinkTo>
          </div>
        {{/if}}

        {{#if @post.caption}}
          <p class="post-caption">{{@post.caption}}</p>
        {{/if}}

        {{#if @post.pinned}}
          <span class="pinned-badge">Featured</span>
        {{/if}}
      </div>
    </LinkTo>
  </template>
}
