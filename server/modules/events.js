import { send, broadcast } from "./messages.js"
import { log, debug } from "./logger.js"

export function onMessage(wss, ws, message) { // fired when we get a message
	debug("Raw message: " + message.toString())
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
			break
		default:
			return console.warn(`Player packet didn't contain "type" value!`)
	}
}

export function onClose(ws) {
	log(`Client disconnected! ID: "${ws.data.id}" IP: "${ws.data.ip}"`)
	send(ws, "player_disconnect", {
		"id": ws.data.id
	})
	ws.terminate()
}