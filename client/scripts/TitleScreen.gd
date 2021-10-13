extends Node2D

onready var play_button = $CanvasLayer/PlayButton
onready var play_menu = $CanvasLayer/PlayMenu

func _on_PlayButton_pressed():
	play_menu.visible = !play_menu.visible
	
