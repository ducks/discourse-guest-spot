import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class GuestSpotFeedRoute extends DiscourseRoute {
  activate() {
    super.activate(...arguments);
    const appController = this.controllerFor("application");
    appController.set("showSidebar", false);
    appController.set("showSidebarToggle", false);
    document.body.classList.add("guest-spot-page");
  }

  deactivate() {
    const appController = this.controllerFor("application");
    appController.set("showSidebar", true);
    appController.set("showSidebarToggle", true);
    document.body.classList.remove("guest-spot-page");
    super.deactivate(...arguments);
  }

  async model() {
    return await ajax("/guest-spot/posts.json");
  }
}
