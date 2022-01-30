import { Entity } from "./Entity.js"

export default class Bullet extends Entity {
	constructor(ws, direction) {
		super(ws.data.position, direction) // initalize entity class
	}
}