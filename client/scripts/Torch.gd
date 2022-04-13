extends Particles2D

func _process(_delta):
	if Global.settings.lighting_effects == true:
		$Light2D.visible = true
	else:
		$Light2D.visible = false
	
	if Global.settings.lighting_particles == true:
		emitting = true
	else:
		emitting = false
