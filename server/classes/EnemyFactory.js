import Enemy from "./Enemy.js"
import { tiles } from "./TileMap.js"

export default class EnemyFactory {
	constructor() {
		this.enemies = new Map()
	}
	createEnemy(pos) {
		var enemy = new Enemy(pos)
		this.enemies.set(enemy.id, enemy)
	}
	spawnEnemies(map, enemiesToSpawn) {
		var enemiesLeft = enemiesToSpawn

		while (enemiesLeft > -1) {
			var pos = [lime.random(0, map.x), lime.random(0, map.y)]
			var tile = map.tiles.get(Number(pos[0]), Number(pos[1]))
			if (!tile) continue
			console.log(`${tile} = ${pos}`)

			if (tile == tiles["floor"]) {
				enemiesLeft--
				this.createEnemy([pos[0] * 32, pos[1] * 32])
			}
		}
		Logger.log(`Spawned in ${enemiesToSpawn - enemiesLeft} enemies!`)
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