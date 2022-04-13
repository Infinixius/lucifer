extends Control

var arrow = load("res://assets/effects/blankpixel.png")

func _ready():
	OS.center_window()
	OS.set_window_maximized(true)
	Global.settings.fullscreen = true
	OS.window_fullscreen = true
	Input.set_custom_mouse_cursor(arrow)

func _on_VideoPlayer_finished():
	get_tree().quit()
