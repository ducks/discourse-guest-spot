import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "hide-sidebar-toggle-on-guest-spot",

  initialize() {
    withPluginApi("0.8", (api) => {
      api.onPageChange((url) => {
        const toggle = document.querySelector(".header-sidebar-toggle");
        if (toggle) {
          if (url.startsWith("/guest-spot")) {
            toggle.style.display = "none";
          } else {
            toggle.style.display = "";
          }
        }
      });
    });
  },
};
