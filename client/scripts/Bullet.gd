extends Area2D

export (int) var speed = 750
export (int) var airtime = 5000

var time = 0
func _physics_process(delta):
	time += delta
	position += transform.y * speed * delta
	if time > airtime:
		queue_free()


func _on_Bullet_body_entered(body):
	if body == $"/root/Game/TileMap":
		$"/root/Game/Players".send("bullet_hit", int($"..".name))
