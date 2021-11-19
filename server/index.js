import * as keylimepiex from "./assets/keylimepie.js"
import https from "https"
import { WebSocketServer } from "ws"
import config from "./config.json" // node must be ran with --experimental-json-modules for this to work
import { send, broadcast } from "./modules/messages.js"
import { log, debug } from "./modules/logger.js"
import { onJoin, onMessage, onClose } from "./modules/events.js"
import { Map } from "./modules/map.js"

if (lime) { log(`Loaded keylimepie v${lime.version}!`) } else { error("Failed to load keylimepie!!!") }

const wss = new WebSocketServer({ port: process.env.PORT || config.port || 8080 })
log("Listening on port " + config.port || process.env.PORT)

// the global object lets us access these variables from any script
global.playerID = 0
global.players = []
global.map = new Map(300, 300, 32)

wss.on("connection", function connection(ws, req) { // initiate player join event
	onJoin(wss, ws, req)
})