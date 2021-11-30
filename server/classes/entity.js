export class Entity {
	constructor(pos, size, rotation) {
		this.position = pos || [0, 0]
		this.size = size || [0, 0]
		this.rotation = rotation || 0
		this.velocity = 0
	}
}