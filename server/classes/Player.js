const { log } = require("../modules/logger.js")
const { BulletFactory } = require("./BulletFactory.js")

module.exports.Player = class Player {
	constructor(client, name) {
		this.client = client // The client is another class, that includes information such as the player's IP address.
		this.name = name

		this.health = 100
		this.maxhealth = 100
		this.position = [128, 128] // X, Y coordinates of the player
		this.killed = false
		this.konami = false
		this.leaving = false

		this.coins = 0
		this.kills = 0

		this.animation = { // The current animation name and frame of the player.
			"name": "walk_up",
			"frame": 0
		}

		this.upgrades = {
			skills: {
				health: 1,
				speed: 1,
				strength: 1,
				luck: 1,
				reload: 1,
				bulletspeed: 1
			},
			abilities: {
				"piercing": false,
				"regeneration": false,
				"rejuvenation": false,
			}
		}
		
		this.bullets = new BulletFactory(this) // A "BulletFactory" is a class that simplifes the creation of Bullet entities.

		setInterval(() => {
			if (this.upgrades.abilities.regeneration) {
				this.heal(this.maxhealth / 100)
			}
		}, 1000)
	}

	hurt(hp, reason) { // The hurt function allows us to hurt the player, taking away some of their health.
		var remaining = Math.round(this.health - hp)
		if (remaining < 1) {
			this.health = 0
			this.kill(reason)
		} else {
			this.health = remaining
		}

		this.client.send("player_hurt", hp)
	}
	heal(hp) {
		var remaining = Math.round(this.health + hp)
		if (remaining > this.maxhealth) {
			this.health = this.maxhealth
		} else {
			this.health = remaining
		}
	}
	kill(reason) { // The kill function will kill the player with a specific reason, such as "burned to death".
		if (!this.killed) {
			this.killed = true
			this.bullets.bullets = new Map()
			global.enemies.enemies.forEach(enemy => {
				if (enemy.owner == this.client.id)  {
					enemy.goToSleep()
				}
			})
			broadcast("player_kill", {
				id: this.client.id,
				reason: reason,
				score: this.coins
			})
			log(`Killed player ${this.name} for reason ${reason}`)
		}
	}
	move(x, y) {
		this.position = [this.position[0] + x, this.position[1] + y]

		this.networkUpdate(true)
	}
	moveTo(x, y) { // The move function moves a player to a specific position.
		this.position = [x, y]

		this.networkUpdate(true)
	}
	upgrade(skill) {
		const cost = this.upgrades.skills[skill] * 100
		if (this.upgrades.skills[skill] > 9) {
			this.client.send("shop_cantafford", true)
			return this.client.send("system_message", `You've already maxed out this skill!`)
		}
		if (this.coins < cost) {
			this.client.send("shop_cantafford", true)
			return this.client.send("system_message", `You can't afford that! You need ${cost - this.coins} more coins!`)
		}

		this.upgrades.skills[skill] ++
		this.coins -= cost

		switch (skill) {
			case "health":
				this.health += 50
				this.maxhealth += 50
		}

		this.client.send("shop_success", true)
		return this.client.send("system_message", `Successfully upgraded ${skill} to Level ${this.upgrades.skills[skill]}. You were charged ${cost} coins.`)

	}
	upgradeAbility(ability) {
		if (this.upgrades.abilities[ability] == true) return this.client.send("system_message", "You already own this ability!")
		if (this.coins < 100) return this.client.send("system_message", `You cant't afford that! You need ${100 - this.coins} more coins!`)
	
		this.upgrades.abilities[ability] = true
		this.coins -= 100

		this.client.send("shop_success", true)
		return this.client.send("system_message", `Successfully upgraded ${ability}! You were charged 100 coins.`)
	}
	networkUpdate(updatePosition) {
		this.client.send("player_update", {
			hp: this.health,
			maxhp: this.maxhealth,
			coins: this.coins,
			kills: this.kills,
			remaining: enemies.enemies.size,
			upgrades: this.upgrades,

			cheats: config.cheats,
			level: global.level
		})

		if (updatePosition) {
			this.client.send("player_update", {
				position: [this.position[0], this.position[1]]
			})
		}

		shadowBroadcast(this.client.id, "player_move", {
			"id": this.client.id,
			"x": this.position[0],
			"y": this.position[1],
			"animation": this.animation.name,
			"animationframe": this.animation.frame
		})
	}
}