extends Node2D

onready var IP = $CanvasLayer/Play/Input_IP
onready var PORT = $CanvasLayer/Play/Input_Port
onready var FadeIn = $CanvasLayer/FadeIn

func _ready():
	$CanvasLayer/Version.text = "v" + Global.VERSION
	
	FadeIn.visible = true
	
	if Global.error != "":
		$CanvasLayer/Play/Error.text = Global.error
		Global.error = ""

func _on_Connect_pressed():
	Global.IP = IP.text
	Global.PORT = PORT.text
	get_tree().change_scene("res://scenes/game/Game.tscn")

var transparency = 1.0
func _process(delta):
	if FadeIn.visible == true and transparency > 0.0:
		transparency -= 0.005
		FadeIn.color = Color(0,0,0, transparency)
	elif transparency < 0.0:
		FadeIn.visible = false



func _on_Options_pressed():
	var options_menu = load("res://scenes/game/OptionsMenu.tscn").instance()
	$CanvasLayer.add_child(options_menu)
	$CanvasLayer/OptionsMenu.connect("CloseOptionsMenu", self,("CloseOptionsMenu"))


func _on_About_pressed():
	pass


func _on_Exit_pressed():
	get_tree().quit()
