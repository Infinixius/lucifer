import { send, broadcast } from "./messages.js"
import { log, debug } from "./logger.js"
import { Player } from "./player.js"

export function onJoin(wss, ws, req) { // fired when a player joins
	playerID += 1
	log(`Client connected! ID: "${playerID}" IP: "${req.socket.remoteAddress}"`)
	ws.data = {
		id: playerID,
		ip: req.socket.remoteAddress,
		req: req
	}
	ws.playerController = new Player(ws)
	players.push(ws)

	let playerArray = []
	for (const player of players) {
		if (typeof player == "undefined") continue // player doesn't exist..?
		playerArray.push({
			"id": player.data.id,
			"position": player.data.position
		})
	}

	broadcast(wss, "system_message", ws.data.id + " connected")
	send(ws, "player_initalize", { // update the player with all currently connected clients and the map
		"id": ws.data.id,
		"players": playerArray
	})
	broadcast(wss, "player_connect", {
		"id": ws.data.id
	})
	map.send(ws)

	// events
	ws.on("message", function incoming(message) { onMessage(wss, ws, message) }) // on message event
	ws.on("close", function incoming(message) {
		onClose(wss, ws)
	})
	setInterval(function() {
		send(ws, "ping", 0)
	}, 1)
}

export function onMessage(wss, ws, message) { // fired when we get a message
	debug("Raw message: " +  message.toString())
	try { var data = JSON.parse(message.toString()) } catch (error) {
		return console.log(error)
	}

	switch (data.type) {
		case "player_move":
			broadcast(wss, "player_move", {
				"id": ws.data.id,
				"x": data.message.x,
				"y": data.message.y
			})
			ws.playerController.hurt(1, "test")
			ws.data.position = [data.message.x, data.message.y]
			break
		case "send_message":
			broadcast(wss, "receive_message", {
				"name": ws.data.id.toString(),
				"message": data.message.slice(0,256)
			})
			break
		default:
			return console.warn(`Player packet didn't contain "type" value!`)
	}
}

export function onClose(wss, ws) {
	broadcast(wss, "system_message", ws.data.id + " disconnected")
	log(`Client disconnected! ID: "${ws.data.id}" IP: "${ws.data.ip}"`)
	
	send(ws, "player_disconnect", {
		"id": ws.data.id
	})

	var player = players.find(plr => { return plr.data.id == ws.data.id })
		players.splice(players.indexOf(player), 1)
	
	ws.terminate()
}