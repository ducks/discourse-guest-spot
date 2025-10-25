import { withPluginApi } from "discourse/lib/plugin-api";
import { schedule } from "@ember/runloop";

export default {
  name: "hide-public-feed-title",

  initialize(container) {
    withPluginApi("1.14.0", (api) => {
      const composer = container.lookup("service:composer");

      const hideTitleField = () => {
        schedule("afterRender", () => {
          const model = composer.model;
          if (!model) return;

          const publicFeedCategory = model.site.categories.find(
            (c) => c.slug === "public-feed"
          );

          if (model.categoryId === publicFeedCategory?.id) {
            const titleInput = document.querySelector("#reply-control .title-input");
            if (titleInput) {
              titleInput.style.display = "none";
            }
          }
        });
      };

      // Check when composer opens or category changes
      composer.addObserver("model.categoryId", hideTitleField);
      composer.addObserver("model", hideTitleField);
    });
  },
};
