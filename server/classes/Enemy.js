import { Entity, EntityTypes } from "./Entity.js"

export default class Enemy extends Entity {
	constructor(pos) {
		super(EntityTypes.Enemy, pos, [1,1]) // initalize entity class
		this.deleted = false

		this.health = 50
	}
}