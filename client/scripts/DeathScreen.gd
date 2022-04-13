extends Control

func _ready():
	$Control/Reason.text = str(Global.deathreason)
	Global.deathreason = ""
	
	$Control/Score.text = "Score: " + str(Global.deathscore)
	Global.deathscore = 0
	
	var tween = $ColorRect/Tween
	tween.interpolate_property($ColorRect, "color",
			Color8(173, 51, 39, 0), Color8(173, 51, 39, 175), 2,
			Tween.TRANS_QUART, Tween.EASE_IN)

	var tween2 = $"/root/Game/Player/AnimatedSprite/Camera2D/Tween"
	tween2.interpolate_property($"/root/Game/Player/AnimatedSprite/Camera2D", "zoom",
			$"/root/Game/Player/AnimatedSprite/Camera2D".zoom, Vector2(0.25, 0.25), 2,
			Tween.TRANS_QUART, Tween.EASE_IN)
	
	var tween3 = $Control/Tween
	tween3.interpolate_property($Control, "modulate",
			Color(1,1,1,0), Color(1,1,1,1), 0.5,
			Tween.TRANS_QUART, Tween.EASE_IN)
	
	tween.start()
	tween2.start()
	
	yield(tween, "tween_completed")
	tween3.start()

func _on_MainMenu_pressed():
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")

func _on_Respawn_pressed():
	$"/root/Game/Players".send("respawn", true)
	
	var tween = $"/root/Game/Player/AnimatedSprite/Camera2D/Tween"
	tween.interpolate_property($"/root/Game/Player/AnimatedSprite/Camera2D", "zoom",
			$"/root/Game/Player/AnimatedSprite/Camera2D".zoom, Vector2(0.6,0.6), 0.25,
			Tween.TRANS_QUART, Tween.EASE_IN)
		
	tween.start()
	
	queue_free()
