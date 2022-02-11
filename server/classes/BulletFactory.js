import Bullet from "./Bullet.js"

export default class BulletFactory {
	constructor(player) {
		this.player = player
		this.bullets = new Map()

		this.lastShot = 0
	}
	createBullet(pos, direction) {
		if (Date.now() - this.lastShot < config.shootCooldown) return

		this.lastShot = Date.now()

		var bullet = new Bullet(pos, direction)
		this.bullets.set(bullet.id, bullet)
	}
	hit(id) {
		if (this.bullets.get(Number(id))) {
			this.bullets.get(Number(id)).deleted = true
		}
	}
	networkUpdate() {
		this.bullets.forEach((bullet, id) => {
			if (Date.now() - bullet.createdAt >= config.bulletLifespan) {
				bullet.deleted = true
			}
			if (bullet.deleted  == true) {
				this.bullets.delete(id)
				broadcast("entity_update", {
					id: id,
					deleted: true
				})
			} else {
				broadcast("entity_update", bullet)
			}
		})
	}
}