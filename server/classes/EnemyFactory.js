import Enemy from "./Enemy.js"

export default class EnemyFactory {
	constructor() {
		this.Enemies = new Map()
	}
	createEnemy(pos) {
		var enemy = new Enemy(pos)
		this.Enemies.set(enemy.id, enemy)
	}
	networkUpdate() {
		this.Enemies.forEach((enemy, id) => {
			enemy.move(1, 1)
			broadcast("entity_update", enemy)
		})
	}
}