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
  @service router;
  @tracked isPinned;
  @tracked isVisible;

  constructor() {
    super(...arguments);
    this.isPinned = this.args.model.guest_spot_post.pinned;
    this.isVisible = this.args.model.guest_spot_post.visible;
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

  @action
  async toggleVisibility() {
    const post = this.args.model.guest_spot_post;
    const newVisibleState = !this.isVisible;

    try {
      const result = await ajax(`/guest-spot/posts/${post.id}`, {
        type: "PUT",
        data: { visible: newVisibleState },
      });

      // Update the tracked property for reactive UI
      this.isVisible = result.guest_spot_post.visible;
      // Also update the model
      post.visible = result.guest_spot_post.visible;
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async deletePost() {
    if (!confirm(i18n("guest_spot.post.delete_confirm"))) {
      return;
    }

    const post = this.args.model.guest_spot_post;

    try {
      await ajax(`/guest-spot/posts/${post.id}`, {
        type: "DELETE",
      });

      this.router.transitionTo("guest-spot-user", post.user.username);
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
              <DButton
                @action={{this.toggleVisibility}}
                @label={{if this.isVisible "guest_spot.post.hide" "guest_spot.post.unhide"}}
                @icon={{if this.isVisible "eye-slash" "eye"}}
                class="btn-default visibility-toggle-btn"
              />
              <DButton
                @action={{this.deletePost}}
                @label="guest_spot.post.delete"
                @icon="trash-alt"
                class="btn-danger delete-post-btn"
              />
            {{/if}}
          </div>
        </div>
      </div>
    </div>
  </template>
}
