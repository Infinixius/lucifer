import Enemy from "./Enemy.js"

export default class EnemyFactory {
	constructor() {
		this.enemies = new Map()
	}
	createEnemy(pos) {
		var enemy = new Enemy(pos)
		this.enemies.set(enemy.id, enemy)
	}
	networkUpdate() {
		this.enemies.forEach((enemy, id) => {
			enemy.move(1, 1)
			if (enemy.deleted  == true) {
				this.enemies.delete(id)
				broadcast("entity_update", {
					id: id,
					deleted: true
				})
			} else {
				broadcast("entity_update", enemy)
			}
		})
	}
}