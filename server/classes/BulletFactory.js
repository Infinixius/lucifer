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
	networkUpdate(skipCache) {
		this.bullets.forEach((bullet, id) => {
			bullet.networkUpdate(skipCache)
			if (bullet.deleted == true) {
				this.bullets.delete(id)
				return
			}
		})
	}
}