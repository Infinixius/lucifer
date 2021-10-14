extends Button

onready var IP = $"../Input_IP"
onready var PORT = $"../Input_Port"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Connect_pressed():
	Global.IP = IP.text
	Global.PORT = PORT.text
	get_tree().change_scene("res://Game.tscn")
