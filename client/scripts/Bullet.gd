extends Area2D

export var speed = 750

func _physics_process(delta):
	position += transform.x * speed * delta



func _on_Bullet_area_entered(area):
	if area.name != "Bullet":
		queue_free()
