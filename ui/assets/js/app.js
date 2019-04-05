import css from "../css/app.css";

require("../css/theme.scss");

import "phoenix_html";

// import socket from "./socket"

import LiveSocket from "phoenix_live_view";

let liveSocket = new LiveSocket("/live");
liveSocket.connect();

document.addEventListener("DOMContentLoaded", () => {
  // Bulma burger menu
  const $navbarBurgers = Array.prototype.slice.call(
    document.querySelectorAll(".navbar-burger"),
    0
  );

  if ($navbarBurgers.length > 0) {
    $navbarBurgers.forEach(el => {
      el.addEventListener("click", () => {
        const target = el.dataset.target;
        const $target = document.getElementById(target);

        el.classList.toggle("is-active");
        $target.classList.toggle("is-active");
      });
    });
  }
});
