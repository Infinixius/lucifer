const { Entity, EntityTypes } = require("./Entity.js")

module.exports.Enemy = class Enemy extends Entity {
	constructor(pos) {
		super(EntityTypes.Enemy, pos, [1,1]) // initalize entity class
		this.deleted = false
		this.asleep = true
		this.owner = 0
		this.lastSeen = 0

		this.health = 50
	}
	hurt(hp, killer) {
		this.awaken(killer)
		var remaining = Math.round(this.health - hp)
		if (remaining < 0) {
			this.health = 0
			this.kill(killer)
		} else {
			this.health = remaining
		}
	}
	kill(killer) {
		if (this.deleted) return
		this.deleted = true

		var client = clients.find(client => client.id == killer)
		if (!client) return

		client.player.coins += lime.random(1,5)
		client.player.kills ++
	}
	awaken(playerID) {
		this.asleep = false
		this.owner = playerID
		this.lastSeen = Date.now()
	}
	goToSleep() {
		this.asleep = true
		this.owner = 0
		this.lastSeen = 0
	}
	networkUpdate(skipCache) {
		if (Date.now() - this.lastSeen > config.enemyForgetTime) {
			this.asleep = true
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