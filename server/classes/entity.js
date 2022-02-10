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
	move(x, y) {
		var oldPos = this.position
		this.position = [oldPos[0] + x, oldPos[1] + y]
	}
	moveTo(x, y) {
		this.position = [x, y]
	}
}

export const EntityTypes = {
	Player: 1,
	Bullet: 2,
	Enemy: 3
}