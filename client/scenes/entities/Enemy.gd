extends KinematicBody2D

export (bool) var asleep = true

func _physics_process(delta):
	if asleep == false:
		var enemy_angle = get_angle_to($"../../../Player".position)
		var vector_angle = Vector2(round(cos(enemy_angle)) * delta, round(sin(enemy_angle)) * delta)
		move_and_slide(vector_angle)
		$"../../../Players".send("enemy_ai", {
			"x": self.position.x,
			"y": self.position.y,
			"id": get_parent().name
		})
