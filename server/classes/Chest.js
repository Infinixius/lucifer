const { Entity, EntityTypes } = require("./Entity.js")

module.exports.Chest = class Chest extends Entity {
	constructor(pos, gold) {
		super(EntityTypes.Chest, pos, [1,1]) // initalize entity class

		this.deleted = false
		this.opened = false
		this.gold = gold ?? false
		this.loot = []
	}
	open(player) {
		if (this.opened) return
		this.opened = true

		var coins = Math.round(lime.random(10, 30) * (player.upgrades.skills.luck / 2))
		var health = Math.round(lime.random(10, 25) * (player.upgrades.skills.luck / 2))

		if (this.gold) {
			coins *= 10
			health *= 10
		}

		this.loot.push(`+${coins} coins`)
		this.loot.push(`+${health} health`)

		player.coins += coins
		player.heal(health)

		for (const lootmessage of this.loot) {
			player.client.send("system_message", lootmessage)
		}
	}
	networkUpdate(skipCache) {
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