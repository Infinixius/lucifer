import { log } from "../modules/logger.js"
import BulletFactory from "./BulletFactory.js"

const names = ["testname1", "testname2", "testname3", "testname4", "testname5"]

export default class Player {
	constructor(client) {
		this.client = client // The client is another class, that includes information such as the player's IP address.
		this.name = names.random() // Chooses a random name from a predefined list that the player can change later.

		this.health = 150
		this.maxhealth = 150
		this.position = [4, 4] // X, Y coordinates of the player

		this.animation = { // The current animation name and frame of the player.
			"name": "walk_up",
			"frame": 0
		}
		
		this.bullets = new BulletFactory(this) // A "BulletFactory" is a class that simplifes the creation of Bullet entities.
	}

	hurt(hp, reason) { // The hurt function allows us to hurt the player, taking away some of their health.
		var remaining = Math.round(this.ws.data.health - hp)
		if (remaining < 0) {
			this.health = 0
			this.kill(reason)
		} else {
			this.health = remaining
		}

		this.networkUpdate(true)
	}
	kill(reason) { // The kill function will kill the player with a specific reason, such as "burned to death".
		log(`Killed player ${this.name} for reason ${reason}`)
	}
	move(x, y) {
		this.position = [this.position[0] + x, this.position[1] + y]
	}
	moveTo(x, y) { // The move function moves a player to a specific position.
		this.position = [x, y]
	}
	networkUpdate(updatePosition) {
		this.client.send("player_update", {
			hp: this.health
		})
		if (updatePosition) {
			this.client.send("player_update", {
				position: [this.position[0], this.position[1]]
			})
		}

		broadcast("player_move", {
			"id": this.client.id,
			"x": this.position[0],
			"y": this.position[1],
			"animation": this.animation.name,
			"animationframe": this.animation.frame
		})
	}
}