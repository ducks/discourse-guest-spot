export default function () {
  this.route("guest-spot-feed", { path: "/guest-spot" });
  this.route("guest-spot-post", { path: "/guest-spot/posts/:id" });
  this.route("guest-spot-user", { path: "/guest-spot/user/:username" });
}
