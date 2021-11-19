import { log } from "./logger.js"
import { send } from "./messages.js"

export class Player {
	constructor(ws) {
		this.ws = ws
		this.ws.data.health = 150
		this.ws.data.maxhealth = 150
		this.ws.data.position = [0,0]
	}
	hurt(hp, reason) {
		var remaining = Math.round(this.ws.data.health - hp)
		if (remaining < 0) {
			this.ws.data.health = 0
			this.kill(reason)
		} else {
			this.ws.data.health = remaining
		}

		send(this.ws, "player_update", {
			hp: remaining
		})
	}
	kill(reason) {
		log(`Killed player id ${this.ws.data.id} for reason ${reason}`)
	}
}