import { Entity } from "./entity.js"

export class Bullet {
	constructor(ws, direction) {
		this.entity = new Entity(ws.data.position, direction)
		
	}
}