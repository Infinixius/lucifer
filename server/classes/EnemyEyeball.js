const { Enemy } = require("./Enemy.js")
const { EntityTypes } = require("./Entity.js")

module.exports.EnemyEyeball = class EnemyEyeball extends Enemy {
	constructor(pos, level) {
		var levelDecider = lime.random(1,30)
		var level
		if (levelDecider >= 25) level = 3
		else if (levelDecider >= 15) level = 2
		else level = 1

		super(pos, EntityTypes.EnemyEyeball, level, "Attacked by an Eyeball.")

		this.health = 50 + (this.level * 10) + (25 * this.level)
		this.damage = [5 + (5 * this.level), 10 + (5 * this.level)]
		this.coinDrops = [5 + (10 * this.level), 20 + (10 * this.level)]
	}
}