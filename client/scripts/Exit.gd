extends Area2D

func _on_Area2D_body_entered(body):
	if body == $"/root/Game/Player":
		$"/root/Game/Players".send("player_exit", true)

func _on_Area2D_body_exited(body):
	if body == $"/root/Game/Player":
		$"/root/Game/Players".send("player_exit", false)
