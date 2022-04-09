extends Particles2D

func _process(_delta):
	if Global.settings.lighting == true:
		$Light2D.visible = true
	else:
		$Light2D.visible = false
