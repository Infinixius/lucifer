extends Control

func _on_Connect_pressed():
	Global.IP = $Label.text
	Global.PORT = "6666"
	Global.saveSettings()
	get_tree().change_scene("res://scenes/game/Game.tscn")
