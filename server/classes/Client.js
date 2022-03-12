const { avoidCircularReference } = require("../modules/utils.js")

module.exports.Client = class Client {
	constructor(ws, req, id) {
		this.ws = ws
        this.req = req
        this.id = id
        this.ip = req.socket.remoteAddress
		this.options = null
		this.lastMessage = Date.now()
		this.kicked = false

		try {
			this.options = new URL(req.url, `http://${req.headers.host}`).searchParams
		} catch (err) {
			Logger.error(`Failed to process options for player #${this.id}! URL: "${req.url}" Error: ${err}`)
		}

        if (req.headers["x-forwarded-for"]) {
            this.ip = req.headers["x-forwarded-for"].split(",")[0].trim() // x-forwarded-for must be used if the server is running behind a reverse proxy
        }

		setInterval(() => {
			if (Date.now() - this.lastMessage > config.playerIdleTime) {
				this.kick("Timed out")
			}
		}, config.tickRate)
	}

    fetchPlayer() {
        return this.ws.player
    }
    
    send(type, message) {
        setTimeout(() => {
			var toSerialize = {
				"type": type,
				"timestamp": Date.now(),
				"message": message
			}
			this.ws.send(JSON.stringify(toSerialize, avoidCircularReference(toSerialize)))
			if (typeof message == "object") {
				Logger.debug(`Sent client #${this.id} message with type "${type}": "${JSON.stringify(message, avoidCircularReference(message))}"`)
			} else {
				Logger.debug(`Sent client #${this.id} message with type "${type}": "${message}"`)
			}
		}, config.fakeLag)
    }

	kick(message) {
		if (this.kicked) return
		this.kicked = true
		this.ws.close(1000, message ?? "No message provided.")
		Logger.log(`Client #${this.id} was kicked for reason "${message ?? "No message provided."}"`)
	}
}