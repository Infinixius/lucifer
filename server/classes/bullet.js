import { Entity, EntityTypes } from "./Entity.js"

export default class Bullet extends Entity {
	constructor(pos, direction) {
		super(EntityTypes.Bullet, pos, [1,1], direction) // initalize entity class
		this.move(16, 16) // offset bullets by 16,16
		this.deleted = false
	}
}