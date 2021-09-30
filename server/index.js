import { WebSocketServer } from "ws"

const wss = new WebSocketServer({ port: 3939 })

wss.on("connection", function connection(ws) {
	ws.on("message", function incoming(message) {
		try { var data = JSON.parse(message) } catch (error) {
			console.log(error)
		}
		console.log("received: %s", message)
	})

	setInterval(function(){
		ws.send(JSON.stringify({
			"type": "move"
		}))
	}, 1000)
})