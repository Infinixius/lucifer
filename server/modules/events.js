import Player from "../classes/Player.js"
import Client from "../classes/Client.js"

export function onJoin(ws, req) { // fired when a player joins
	playerID++
	ws.client = new Client(ws, req, playerID)
	ws.player = new Player(ws.client)

	Logger.log(`Client connected! ID: "${playerID}" IP: "${ws.client.ip}"`)
	clients.push(ws.client)

	let playerArray = []
	for (const client of clients) {
		playerArray.push({
			"id": client.id,
			"position": client.fetchPlayer().position
		})
	}

	broadcast("system_message", ws.player.name + " connected")
	ws.client.send("player_initalize", {
		"id": ws.client.id,
		"players": playerArray
	})
	broadcast("player_connect", {
		"id": ws.client.id
	})
	map.send(ws)

	// events
	ws.on("message", (msg) => { onMessage(ws, msg) }) // on message event
	ws.on("close", () => { onClose(ws, ws) })

	// ping
	setInterval(function() {
		ws.client.send("ping", { timestamp: Date.now() })
	}, config.pingInterval)
}

export function onMessage(ws, message) { // fired when we get a message
	Logger.debug(`Raw message received from client #${ws.client.id}: "${message.toString()}"`)
	try { var data = JSON.parse(message.toString()) } catch (err) {
		return Logger.error(`Failed to parse data received from client #${ws.client.id}! Error: ${err}`)
	}

	switch (data.type) {	 
		case "player_move":
			broadcast("player_move", {
				"id": ws.client.id,
				"x": data.message.x,
				"y": data.message.y,
				"animation": data.message.animation,
				"animationframe": data.message.animationframe
			})
			ws.player.move(data.message.x, data.message.y)
			break
		case "send_message":
			broadcast("receive_message", {
				"name": ws.player.name,
				"message": data.message.slice(0,256)
			})
			break
		case "player_shoot":
			if (Date.now() - ws.player.lastShot > config.shootCooldown) {
				broadcast("player_shoot", {
					"id": ws.client.id,
					"rotation": data.message.direction,
					"position": ws.player.position
				})
				ws.player.lastShot = Date.now()
			}
			break
	}
}

export function onClose(ws) {
	broadcast( "system_message", ws.player.name + " disconnected")
	Logger.log(`Client #${ws.client.id} disconnected!"`)
	
	broadcast("player_disconnect", ws.client.id)

	var player = clients.find(plr => { return plr.id == ws.client.id })
		clients.splice(clients.indexOf(player), 1)
	
	ws.terminate()
}