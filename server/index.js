import { WebSocketServer } from "ws"
import config from "./config.json" // node must be ran with --experimental-json-modules for this to work
import { send, broadcast } from "./modules/messages.js"
import { log, debug } from "./modules/logger.js"
import { onMessage, onClose } from "./modules/events.js"

const wss = new WebSocketServer({ port: config.port })
log("Listening on port " + config.port)

var playerID = 0
var players = []

wss.on("connection", function connection(ws, req) { // initiate player join event
	playerID += 1
	log(`Client connected! ID: "${playerID}" IP: "${req.socket.remoteAddress}"`)
	ws.data = {
		id: playerID,
		ip: req.socket.remoteAddress
	}
	players.push({
		"id": ws.data.id,
		"ws": ws,
		"req": req,
		"ip": req.socket.remoteAddress
	})

	broadcast(wss, "player_connect", {
		"id": ws.data.id
	})

	let playerArray = []
	for (const player of players) {
		playerArray.push({
			"id": player.id
		})
	}
	
	send(ws, "player_initalize", { // update the player with all currently connected clients
		"id": ws.data.id,
		"players": playerArray
	})

	ws.on("message", function incoming(message) { onMessage(wss, ws, message) }) // on message event
	ws.on("close", function incoming(message) {
		onClose(ws)
		delete player.find(plr => {return plr.id == ws.data.id})
	})
	setInterval(function() {
		send(ws, "ping", 0)
	}, 500)
})