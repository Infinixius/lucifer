const { Entity, EntityTypes } = require("./Entity.js")

module.exports.Bullet = class Bullet extends Entity {
	constructor(pos, direction, speed) {
		super(EntityTypes.Bullet, pos, [1,1], direction) // initalize entity class
		this.move(16, 16) // offset bullets by 16,16
		this.deleted = false
		this.velocity = speed
	}
	networkUpdate(skipCache) {
		if (Date.now() - this.createdAt >= config.bulletLifespan) {
			this.deleted = true
		}

		if (this.deleted == true) {
			return broadcast("entity_update", {
				id: this.id,
				deleted: true
			})
		}
		
		if (skipCache) {
			if (!this.deleted) {
				broadcast("entity_update", this)
			}
		} else {
			if (this.cache.check(this) && !this.deleted) {
				broadcast("entity_update", this)
			}
		}
	}
}