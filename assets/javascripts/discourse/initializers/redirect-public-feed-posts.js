import { withPluginApi } from "discourse/lib/plugin-api";
import { next } from "@ember/runloop";

export default {
  name: "redirect-public-feed-posts",

  initialize(container) {
    withPluginApi("1.14.0", (api) => {
      const router = container.lookup("service:router");
      const appEvents = container.lookup("service:app-events");
      const site = container.lookup("service:site");

      // Listen for topic created event and redirect to guest spot post view
      // Event passes (createdPost, composerModel)
      appEvents.on("topic:created", (createdPost, composerModel) => {
        const category = site.categories.find((c) => c.slug === "public-feed");

        if (composerModel.categoryId === category?.id) {
          // Use next() to let the default redirect happen first, then override
          next(() => {
            router.transitionTo("guest-spot-post", createdPost.topic_id);
          });
        }
      });
    });
  },
};
