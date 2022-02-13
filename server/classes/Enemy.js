import { Entity, EntityTypes } from "./Entity.js"

export default class Enemy extends Entity {
	constructor(pos) {
		super(EntityTypes.Enemy, pos, [1,1]) // initalize entity class
		this.deleted = false
		this.asleep = true
		this.owner = 0
		this.lastSeen = 0

		this.health = 50
	}
	hurt(hp) {
		var remaining = Math.round(this.health - hp)
		if (remaining < 0) {
			this.health = 0
			this.kill()
		} else {
			this.health = remaining
		}
	}
	kill() {
		this.deleted = true
	}
	awaken(playerID) {
		this.asleep = false
		this.owner = playerID
		this.lastSeen = Date.now()
	}
	networkUpdate() {
		if (!this.asleep) {
			this.move(1, 1)
		}
		if (Date.now() - this.lastSeen > config.enemyForgetTime) {
			this.asleep = true
		}
	}
}