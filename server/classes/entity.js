export class Entity {
	constructor(type, pos, size, rotation) {
		this.type = type
		this.position = pos || [0, 0]
		this.size = size || [1, 1]
		this.rotation = rotation || 0
		this.velocity = 0
		
		global.uid++
		this.id = global.uid
		this.createdAt = Date.now()
	}
}

export const EntityTypes = {
	Bullet: 2
}