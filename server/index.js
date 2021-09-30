import { WebSocketServer } from "ws"

const wss = new WebSocketServer({ port: 3939 })

function send(message, ws) {
	ws.send(JSON.stringify(message))
}

function broadcast(message) {
	wss.clients.forEach(function each(client){
		client.send(JSON.stringify(message))
	})
}

var playerID = 0
var playerIDArray = []
var players = {}

wss.on("connection", function connection(ws) {
	playerID += 1
	console.log("Player connected with ID " + playerID)
	let currentID = playerID
	players[playerID] = ws
	playerIDArray.push(playerID)
	broadcast({
		"type": "player_connect",
		"id": currentID,
	}, ws)

	send({
		"type": "player_initalize",
		"id": currentID,
		"players": playerIDArray
	}, ws)

	ws.on("message", function incoming(message) {
		console.log(message.toString())
		try { var data = JSON.parse(message) } catch (error) {
			return console.log(error)
		}

		switch (data.type) {
			case "player_move":
				broadcast({
					"type": "player_move",
					"id": currentID,
					"x": data.x,
					"y": data.y
				}, ws)
				break
			default:
				return console.warn(`Player packet didn't contain "type" value!`)
		}
	})
})