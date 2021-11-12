extends Control

signal CloseOptionsMenu


func _on_Exit_pressed():
	emit_signal("CloseOptionsMenu")
