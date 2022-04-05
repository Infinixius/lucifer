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
	spawnEnemies(map, enemiesToSpawn) {
		var enemiesLeft = enemiesToSpawn - 1

		while (enemiesLeft > -1) {
			var pos = [lime.random(0, map.x), lime.random(0, map.y)]
			var tile = map.tiles.get(Number(pos[0]), Number(pos[1]))
			if (!tile) continue

			if (tile == tiles["floor"]) {
				enemiesLeft--
				this.createEnemy([pos[0] * 32, pos[1] * 32])
			}
		}
		Logger.log(`Spawned in ${enemiesToSpawn - 1 - enemiesLeft} enemies!`)
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