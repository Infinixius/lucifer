const { Bullet } = require("./Bullet.js")

module.exports.BulletFactory = class BulletFactory {
	constructor(player) {
		this.bullets = new Map()
		this.playerID = player.client.id

		this.lastShot = 0
	}
	createBullet(pos, direction) {
		var player = clients.find(client => client.id == this.playerID).fetchPlayer()
		var cooldown = config.shootCooldown
		if (player) cooldown = cooldown - (25 * player.upgrades.skills.reload)
		if (Date.now() - this.lastShot < cooldown) return

		this.lastShot = Date.now()

		var bullet = new Bullet(pos, direction, 500 + (100 * player.upgrades.skills.bulletspeed))
		this.bullets.set(bullet.id, bullet)
	}
	hit(id, collision) {
		var bullet = this.bullets.get(Number(id))
		if (bullet) {
			bullet.deleted = true
			
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