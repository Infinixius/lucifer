const { Entity, EntityTypes } = require("./Entity.js")

module.exports.Enemy = class Enemy extends Entity {
	constructor(pos, type, level, attackReason) {
		super(type ?? EntityTypes.Enemy, pos, [1,1]) // initalize entity class
		this.level = level ?? 1
		this.deleted = false
		this.asleep = true
		this.owner = 0
		this.lastSeen = 0
		this.lastAttack = Date.now()

		this.health = 10 + (global.level * 10)
		this.speed = 100
		this.damage = [5, 10]
		this.coinDrops = [5, 15]
		this.attackReason = attackReason ?? "Attacked by an enemy."
	}
	hurt(hp, killer) {
		this.awaken(killer)
		broadcast("enemy_hurt", this.id)
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
		var player = client.fetchPlayer()

		player.coins += Math.round(lime.random(this.coinDrops[0], this.coinDrops[1]) * (player.upgrades.skills.luck / 2))
		player.kills ++
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
	attack(player) {
		if (Date.now() - this.lastAttack > config.enemyAttackTime) {
			player.hurt(lime.random(this.damage[0], this.damage[1]), this.attackReason)
			this.lastAttack = Date.now()
		}
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