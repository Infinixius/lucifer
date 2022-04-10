const { Enemy } = require("./Enemy.js")
const { tiles } = require("./TileMap.js")

module.exports.EnemyFactory = class EnemyFactory {
	constructor() {
		this.enemies = new Map()
	}
	createEnemy(pos) {
		var enemy = new Enemy(pos)
		this.enemies.set(enemy.id, enemy)
	}
	spawnEnemies(map, spawners) {
		var spawnedEnemies = 0
		for (const spawner of spawners) {
			this.createEnemy([spawner [0] * 32, spawner [1] * 32])
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