extends Button

onready var IP = $"../Input_IP"
onready var PORT = $"../Input_Port"

func _on_Connect_pressed():
	Global.IP = IP.text
	Global.PORT = PORT.text
	get_tree().change_scene("res://Game.tscn")
