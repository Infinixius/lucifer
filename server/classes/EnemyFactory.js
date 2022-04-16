const { Enemy } = require("./Enemy.js")
const { EnemyEyeball } = require("./EnemyEyeball.js")

module.exports.EnemyFactory = class EnemyFactory {
	constructor() {
		this.enemies = new Map()
	}
	createEnemy(pos) {
		var rand = lime.random(1,2)
		var enemy
		if (rand == 1) {
			enemy = new EnemyEyeball(pos)
		} else if (rand == 2) {
			enemy = new EnemyEyeball(pos)
		}
		
		this.enemies.set(enemy.id, enemy)
	}
	spawnEnemies(spawners) {
		var spawnedEnemies = 0
		for (const spawner of spawners) {
			this.createEnemy([spawner [0] * 32 + 16, spawner [1] * 32 + 16])
			spawnedEnemies++
		}
		Logger.log(`Spawned in ${spawnedEnemies} enemies!`)
	}
	networkUpdate(skipCache) {
		this.enemies.forEach((enemy, id) => {
			enemy.networkUpdate(skipCache)
			if (enemy.deleted == true) {
				this.enemies.delete(id)
				return
			}
		})
	}
}