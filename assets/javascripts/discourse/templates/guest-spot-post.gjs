import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { LinkTo } from "@ember/routing";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class GuestSpotPost extends Component {
  @service currentUser;
  @tracked isPinned;

  constructor() {
    super(...arguments);
    this.isPinned = this.args.model.guest_spot_post.pinned;
  }

  get canManagePin() {
    return (
      this.currentUser &&
      this.currentUser.id === this.args.model.guest_spot_post.user_id
    );
  }

  @action
  async togglePin() {
    const post = this.args.model.guest_spot_post;
    const newPinnedState = !this.isPinned;

    try {
      const result = await ajax(`/guest-spot/posts/${post.id}`, {
        type: "PUT",
        data: { pinned: newPinnedState },
      });

      // Update the tracked property for reactive UI
      this.isPinned = result.guest_spot_post.pinned;
      // Also update the model
      post.pinned = result.guest_spot_post.pinned;
    } catch (error) {
      popupAjaxError(error);
    }
  }

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
              <LinkTo
                @route="guest-spot-user"
                @model={{@model.guest_spot_post.user.username}}
                class="username-link"
              >
                <h2 class="username">{{@model.guest_spot_post.user.username}}</h2>
              </LinkTo>
              {{#if this.isPinned}}
                <span class="pinned-badge">Featured</span>
              {{/if}}
            </div>
          </div>

          {{#if @model.guest_spot_post.caption}}
            <p class="post-caption">{{@model.guest_spot_post.caption}}</p>
          {{/if}}

          <div class="post-meta">
            <span class="post-date">{{@model.guest_spot_post.created_at}}</span>
            {{#if this.canManagePin}}
              <DButton
                @action={{this.togglePin}}
                @label={{if this.isPinned "guest_spot.post.unpin" "guest_spot.post.pin"}}
                @icon={{if this.isPinned "unlink" "thumbtack"}}
                class="btn-default pin-toggle-btn"
              />
            {{/if}}
          </div>
        </div>
      </div>
    </div>
  </template>
}
