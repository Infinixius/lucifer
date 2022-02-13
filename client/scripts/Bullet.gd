extends Area2D

export (int) var speed = 750
export (int) var airtime = 5000

var time = 0
func _physics_process(delta):
	time += delta
	position += transform.y * speed * delta
	if time > airtime:
		queue_free()
	if Global.settings.lighting == true:
		$Sprite/Light2D.visible = true
	else:
		$Sprite/Light2D.visible = false


func _on_Bullet_body_entered(body):
	if body == $"/root/Game/TileMap":
		$"../../../Sounds".play("WallHit")
		$"/root/Game/Players".send("bullet_hit", {
			"type": "wall",
			"id": int($"..".name)
		})


func _on_Bullet_area_entered(area):
	if area.get_parent().name == "Enemy":
		$"../../../Sounds".play("EnemyHit")
		$"/root/Game/Players".send("bullet_hit", {
				"type": "enemy",
				"id": int(area.get_parent().get_parent().name),
				"bullet": $"..".name
			})
