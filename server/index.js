import https from "https"
import { WebSocketServer } from "ws"
import config from "./config.json" // node must be ran with --experimental-json-modules for this to work
import { send, broadcast } from "./modules/messages.js"
import { log, debug } from "./modules/logger.js"
import { onMessage, onClose } from "./modules/events.js"
import { sendMap } from "./modules/map.js"

const wss = new WebSocketServer({ port: process.env.PORT || config.port || 8080 })
log("Listening on port " + config.port || process.env.PORT)

var playerID = 0
var players = []

wss.on("connection", function connection(ws, req) { // initiate player join event
	playerID += 1
	log(`Client connected! ID: "${playerID}" IP: "${req.socket.remoteAddress}"`)

	// setup player on the server

	ws.data = {
		id: playerID,
		ip: req.socket.remoteAddress,
		position: [0,0]
	}
	players.push({
		"id": ws.data.id,
		"ws": ws,
		"req": req,
		"ip": req.socket.remoteAddress
	})

	// setup the player

	let playerArray = []
	for (const player of players) {
		if (typeof player == "undefined") continue // player doesn't exist..?
		playerArray.push({
			"id": player.id,
			"position": player.ws.data.position
		})
	}
	
	broadcast(wss, "system_message", ws.data.id + " connected")
	send(ws, "player_initalize", { // update the player with all currently connected clients
		"id": ws.data.id,
		"players": playerArray
	})

	broadcast(wss, "player_connect", {
		"id": ws.data.id
	})
	sendMap(ws)

	// events code

	ws.on("message", function incoming(message) { onMessage(wss, ws, message) }) // on message event
	ws.on("close", function incoming(message) {
		broadcast(wss, "system_message", ws.data.id + " disconnected")
		send(ws, "player_disconnect", { // update the player with all currently connected clients
			"id": ws.data.id
		})
		var player = players.find(plr => { return plr.id == ws.data.id })
		players.splice(players.indexOf(player), 1)
		onClose(ws)
	})
	setInterval(function() {
		send(ws, "ping", 0)
	}, 1)
})