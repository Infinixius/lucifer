import { log } from "../modules/logger.js"
import BulletFactory from "./BulletFactory.js"

const names = ["testname1", "testname2", "testname3", "testname4", "testname5"]

export default class Player {
	constructor(client) {
		this.client = client
		this.name = names.random()

		this.health = 150
		this.maxhealth = 150
		this.position = [0,0]

		this.animation = {
			"name": "walk_up",
			"frame": 0
		}
		this.bullets = new BulletFactory(this)
	}

	hurt(hp, reason) {
		var remaining = Math.round(this.ws.data.health - hp)
		if (remaining < 0) {
			this.health = 0
			this.kill(reason)
		} else {
			this.health = remaining
		}

		this.client.send("player_update", {
			hp: remaining
		})
	}
	kill(reason) {
		log(`Killed player ${this.name} for reason ${reason}`)
	}
	move(x,y) {
		this.position = [x, y]
	}
	networkUpdate() {
		broadcast("player_move", {
			"id": this.client.id,
			"x": this.position[0],
			"y": this.position[1],
			"animation": this.animation.name,
			"animationframe": this.animation.frame
		})
	}
}