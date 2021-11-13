extends Node2D

export var health = 1000



func _on_Area2D_area_entered(area):
	if area.name == "Hit":
		pass
	elif area.name == "Bullet":
		health -= 50


func _process(delta):
	if health <= 0:
		queue_free()
