import { Entity, EntityTypes } from "./Entity.js"

export default class Bullet extends Entity {
	constructor(pos, direction) {
		super(EntityTypes.Bullet, pos, direction) // initalize entity class
	}
}