import Component from "@glimmer/component";
import avatar from "discourse/helpers/avatar";
import replaceEmoji from "discourse/helpers/replace-emoji";
import formatDate from "discourse/helpers/format-date";

export default class GuestSpotItem extends Component {
  get isPublicFeed() {
    return this.args.outletArgs?.topic?.category?.slug === "public-feed";
  }

  get truncatedExcerpt() {
    const excerpt = this.args.outletArgs?.topic?.excerpt || "";
    if (excerpt.length <= 50) {
      return excerpt;
    }
    return excerpt.substring(0, 50) + "...";
  }

  <template>
    {{#if this.isPublicFeed}}
      <td class="topic-list-data guest-spot-card">
        {{#if this.args.outletArgs.topic.creator}}
          <div class="guest-spot-author">
            <a href="/u/{{this.args.outletArgs.topic.creator.username}}" data-user-card={{this.args.outletArgs.topic.creator.username}}>
              {{avatar this.args.outletArgs.topic.creator imageSize="medium"}}
              <span class="username">{{this.args.outletArgs.topic.creator.username}}</span>
            </a>
          </div>
        {{/if}}

        {{#if this.args.outletArgs.topic.image_url}}
          <div class="guest-spot-image">
            <a href={{this.args.outletArgs.topic.url}}>
              <img src={{this.args.outletArgs.topic.image_url}} alt="" />
            </a>
          </div>
        {{/if}}

        {{#if this.truncatedExcerpt}}
          <div class="guest-spot-excerpt">{{replaceEmoji this.truncatedExcerpt}}</div>
        {{/if}}

        <div class="guest-spot-metadata">
          <div class="meta-item">Views: {{this.args.outletArgs.topic.views}}</div>
          <div class="meta-item">Replies: {{this.args.outletArgs.topic.posts_count}}</div>
          <div class="meta-item">Posted: {{formatDate this.args.outletArgs.topic.createdAt leaveAgo=true}}</div>
        </div>
      </td>
    {{else}}
      {{@default}}
    {{/if}}
  </template>
}
