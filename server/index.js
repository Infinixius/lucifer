const { WebSocketServer } = require("ws")
const { avoidCircularReference } = require("./modules/utils.js")
const config = require("./config.json")
require("./assets/keylimepie.js")

global.lan = process.argv.includes("--langame")
if (process.argv.includes("--cheats")) {
	config.cheats = true
}

if (global.lan) {
	config.cheats = process.argv.includes("--cheats")
}

const Logger = require("./modules/logger.js")
const { consoleCommand } = require("./modules/commands.js")
const { onJoin } = require("./modules/events.js")
const { Map } = require("./classes/map.js")
const { EnemyFactory } = require("./classes/EnemyFactory.js")
require("./modules/lanscanner.server.js")

if (lime) { Logger.log(`Loaded keylimepie v${lime.version}!`) } else { Logger.error("Failed to load keylimepie!!!") }
Logger.log(`Debugging mode is currently ${config.dev ? "enabled" : "disabled"}`)
Logger.log(`Cheats are currently ${config.cheats ? "enabled" : "disabled"}`)


// the global object lets us access these variables from any script
global.wss = new WebSocketServer({ port: process.env.PORT || config.port || 8080 })
global.config = config
global.Logger = Logger

global.playerID = 0
global.uid = 0 // a unique identifier used for enemies, bullets, etc
global.clients = []
global.level = 1
global.map = new Map(1000, 1000, global.level * 15)
global.enemies = new EnemyFactory()
global.ticks = 0

setInterval(() => {
	global.ticks ++
	global.enemies.networkUpdate()
	global.map.networkUpdate()
	clients.forEach(client => {
		var player = client.fetchPlayer()
		player.networkUpdate()
		player.bullets.networkUpdate()
	})

	if (clients.length > 0 && clients.every(client => client.fetchPlayer().leaving)) {
		clients.forEach(client => { client.fetchPlayer().leaving = false })
		broadcast("newlevel", true)

		setTimeout(() => {
			global.level ++
			global.map = new Map(1000, 1000, global.level * 15)
			global.enemies = new EnemyFactory()
			clients.forEach(client => {
				client.fetchPlayer().moveTo(128, 128)
			})
		}, 2000)
	}
}, config.tickRate)

// utility functions available in every script
global.broadcast = function(type, message) {
	setTimeout(() => {
		if (typeof message == "object") {
			try {
				Logger.debug(`Broadcasted message to every client with type "${type}": "${JSON.stringify(message, avoidCircularReference(message))}"`)
			} catch (err) {
				Logger.debug(`Broadcasted message to every client with type "${type}": "${message}"`)
			}
		} else {
			Logger.debug(`Broadcasted message to every client with type "${type}": "${message}"`)
		}
		
		wss.clients.forEach((client) => {
			try {
				var toSerialize = {
					"type": type,
					"timestamp": Date.now(),
					"message": message
				}
				client.send(JSON.stringify(toSerialize, avoidCircularReference(toSerialize)))
			} catch (err) {
				Logger.warn(`Failed to send message to all clients! Message: ${toSerialize}`)
			}
		})
	}, config.fakeLag)
}

global.shadowBroadcast = function(id, type, message) { // send a message to every client except one
	setTimeout(() => {
		if (typeof message == "object") {
			Logger.debug(`Shadowbroadcasted message to every client (except #${id}) with type "${type}": "${JSON.stringify(message, avoidCircularReference(message))}"`)
		} else {
			Logger.debug(`Shadowbroadcasted message to every client (except #${id}) with type "${type}": "${message}"`)
		}
		
		wss.clients.forEach((client) => {
			if (client.id == id) return
			try {
				var toSerialize = {
					"type": type,
					"timestamp": Date.now(),
					"message": message
				}
				client.send(JSON.stringify(toSerialize, avoidCircularReference(toSerialize)))
			} catch (err) {
				Logger.warn(`Failed to send message to all clients! Message: ${toSerialize}`)
			}
		})
	}, config.fakeLag)
}

wss.on("connection", (ws, req) => { onJoin(ws, req) })
wss.on("listening", () => {
    Logger.log(`Listening on port ${process.env.PORT || config.port || 8080}`)
    console.log("---------------------------------------------")
	consoleCommand() // initalize the console command listener
})
wss.on("error", (err) => {
	Logger.error(`Could not open server on port ${process.env.PORT || config.port || 8080}! Error: ${err}`)
	process.exit()
})
process.on("uncaughtException", (err) => {
    Logger.error("Uncaught exception occured! Error:")
    Logger.rawerror(err)
})