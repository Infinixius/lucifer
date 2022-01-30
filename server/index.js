import { WebSocketServer } from "ws"
import config from "./config.json"
import "./assets/keylimepie.js"

import * as Logger from "./modules/logger.js"
import { onJoin } from "./modules/events.js"
import Map from "./classes/map.js"

if (lime) { Logger.log(`Loaded keylimepie v${lime.version}!`) } else { Logger.error("Failed to load keylimepie!!!") }
Logger.log(`Debugging mode is currently ${config.dev ? "enabled" : "disabled"}`)

const wss = new WebSocketServer({ port: process.env.PORT || config.port || 8080 })

// the global object lets us access these variables from any script
global.wss = wss
global.config = config
global.Logger = Logger

global.playerID = 0
global.clients = []
global.map = new Map(300, 300, 32)

// utility functions available in every script
global.broadcast = function(type, message) {
    Logger.debug(`Broadcasted message to every client with type "${type}": "${message}"`)
    wss.clients.forEach((client) => {
        client.send(JSON.stringify({
            "type": type,
            "timestamp": Date.now(),
            "message": message
        }))
    })
}

wss.on("connection", (ws, req) => { onJoin(ws, req) })
wss.on("listening", () => {
    Logger.log("Listening on port " + config.port || process.env.PORT)
    console.log("---------------------------------------------")
})
process.on("uncaughtException", (err) => {
    Logger.error("Uncaught exception occured! Error:")
    Logger.rawerror(err)
})