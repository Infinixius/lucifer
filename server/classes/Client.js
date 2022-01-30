export default class Client {
	constructor(ws, req, id) {
		this.ws = ws
        this.req = req
        this.id = id
        this.ip = req.socket.remoteAddress // x-forwarded-for must be used if the server is running behind a reverse proxy

        if (req.headers["x-forwarded-for"]) {
            this.ip = req.headers["x-forwarded-for"].split(",")[0].trim() // x-forwarded-for must be used if the server is running behind a reverse proxy
        }
	}

    fetchPlayer() {
        return this.ws.player
    }
    send(type, message) {
        this.ws.send(JSON.stringify({
            "type": type,
            "timestamp": Date.now(),
            "message": message
        }))
        Logger.debug(`Sent client #${this.id} message with type "${type}": "${message}"`)
    }
}