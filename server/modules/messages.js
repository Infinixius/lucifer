export function send(ws, type, message) { // send a message to a single client
	ws.send(JSON.stringify({
		"type": type,
		"timestamp": Date.now(),
		"message": message
	}))
}

export function broadcast(wss, type, message) { // send a message to all clients
	wss.clients.forEach(function each(client) {
		client.send(JSON.stringify({
			"type": type,
			"timestamp": Date.now(),
			"message": message
		}))
	})
}