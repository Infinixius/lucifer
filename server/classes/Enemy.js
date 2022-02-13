import { Entity, EntityTypes } from "./Entity.js"

export default class Enemy extends Entity {
	constructor(pos) {
		super(EntityTypes.Enemy, pos, [1,1]) // initalize entity class
		this.deleted = false

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
}