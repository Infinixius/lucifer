import { WebSocketServer } from "ws"
import config from "./config.json"
import "./assets/keylimepie.js"

import * as Logger from "./modules/logger.js"
import { consoleCommand 	} from "./modules/commands.js"
import { onJoin } from "./modules/events.js"
import Map from "./classes/map.js"
import EnemyFactory from "./classes/EnemyFactory.js"

if (lime) { Logger.log(`Loaded keylimepie v${lime.version}!`) } else { Logger.error("Failed to load keylimepie!!!") }
Logger.log(`Debugging mode is currently ${config.dev ? "enabled" : "disabled"}`)

const wss = new WebSocketServer({ port: process.env.PORT || config.port || 8080 })

// the global object lets us access these variables from any script
global.wss = wss
global.config = config
global.Logger = Logger

global.playerID = 0
global.uid = 0 // a unique identifier used for enemies, bullets, etc
global.clients = []
global.map = new Map(500, 500, 32)
global.enemies = new EnemyFactory()

enemies.createEnemy([5, 5])

setInterval(() => {
	global.enemies.networkUpdate()
	clients.forEach(client => {
		var player = client.fetchPlayer()
		player.networkUpdate()
		player.bullets.networkUpdate()
	})
}, config.tickRate)

// utility functions available in every script
global.broadcast = function(type, message) {
	setTimeout(() => {
		if (typeof message == "object") {
			Logger.debug(`Broadcasted message to every client with type "${type}": "${JSON.stringify(message)}"`)
		} else {
			Logger.debug(`Broadcasted message to every client with type "${type}": "${message}"`)
		}
		
		wss.clients.forEach((client) => {
			client.send(JSON.stringify({
				"type": type,
				"timestamp": Date.now(),
				"message": message
			}))
		})
	}, config.fakeLag)
}

wss.on("connection", (ws, req) => { onJoin(ws, req) })
wss.on("listening", () => {
    Logger.log("Listening on port " + config.port || process.env.PORT)
    console.log("---------------------------------------------")
	consoleCommand() // initalize the console command listener
})
process.on("uncaughtException", (err) => {
    Logger.error("Uncaught exception occured! Error:")
    Logger.rawerror(err)
})