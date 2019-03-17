import css from "../css/app.css"

require('../css/theme.scss');

import "phoenix_html"

// import socket from "./socket"

import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

