extends Area2D

export (int) var speed = 500

var time = 0
func _physics_process(delta):
	time += delta
	position += transform.y * speed * delta
	if Global.settings.lighting == true:
		$Sprite/Light2D.visible = true
	else:
		$Sprite/Light2D.visible = false

func _on_Bullet_body_entered(body):
	if body == $"/root/Game/Navigation2D/TileMap":
		$"../../../Sounds".play("WallHit")
		$"/root/Game/Players".send("bullet_hit", {
			"type": "wall",
			"id": int($"..".name)
		})
	elif body.name == "Enemy":
		$"../../../Sounds".play("EnemyHit")
		$"/root/Game/Players".send("bullet_hit", {
				"type": "enemy",
				"id": int(body.get_parent().name),
				"bullet": $"..".name
			})
