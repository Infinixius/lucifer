extends ConfirmationDialog

func _ready():
	popup()

func _on_StartLANGame_confirmed():
	Global.StartLANGame($Options/VBoxContainer/Cheats.toggle_mode)

func _on_StartLANGame_about_to_show():
	$Tween.interpolate_property(self, "rect_position",
		Vector2(765, 1311), Vector2(765, 311), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()


func _on_StartLANGame_popup_hide():
	$Tween.interpolate_property(self, "rect_position",
		Vector2(765, 311), Vector2(765, 1311), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	queue_free()
