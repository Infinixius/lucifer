extends Node2D

func _ready():
	yield(get_tree().create_timer(3), "timeout")
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
