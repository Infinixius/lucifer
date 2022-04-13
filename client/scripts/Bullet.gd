extends Area2D

export (int) var speed = 500
var BulletPuff = load("res://scenes/entities/BulletPuff.tscn")
var BulletHitPuff = load("res://scenes/entities/BulletHitPuff.tscn")

var time = 0
func _physics_process(delta):
	time += delta
	position += transform.y * speed * delta
	if Global.settings.lighting_effects == true:
		$Sprite/Light2D.visible = true
	else:
		$Sprite/Light2D.visible = false
	if Global.settings.lighting_particles == true:
		$Particles2D.visible = true
	else:
		$Particles2D.visible = false

func _on_Bullet_body_entered(body):
	if body == $"/root/Game/Navigation2D/TileMap":
		$"../../../Sounds".play("WallHit")
		self.visible = false
		
		if Global.settings.lighting_particles == true:
			var bulletpuff = BulletPuff.instance()
			bulletpuff.position = $ParticlePoint.global_position
			bulletpuff.rotation = $ParticlePoint.global_rotation
			bulletpuff.emitting = true
			$"/root/Game".add_child(bulletpuff)
		
		$"/root/Game/Players".send("bullet_hit", {
			"type": "wall",
			"id": int($"..".name)
		})
	elif body.name == "Enemy":
		$"../../../Sounds".play("EnemyHit")
		
		if Global.settings.lighting_particles == true:
			var bullethitpuff = BulletHitPuff.instance()
			bullethitpuff.emitting = true
			bullethitpuff.process_material.color = body.enemyColor
			body.add_child(bullethitpuff)
		
		$"/root/Game/Players".send("bullet_hit", {
				"type": "enemy",
				"id": int(body.get_parent().name),
				"bullet": $"..".name
			})
