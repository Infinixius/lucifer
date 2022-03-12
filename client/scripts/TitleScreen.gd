extends Node2D

onready var IP = $CanvasLayer/Play/Input_IP
onready var PORT = $CanvasLayer/Play/Input_Port
onready var NAME = $CanvasLayer/Play/Input_Name
onready var FadeIn = $CanvasLayer/FadeIn

func _ready():
	$CanvasLayer/Version.text = "v" + Global.VERSION
	if Global.settings.name != "":
		NAME.text = Global.settings.name
	elif OS.has_environment("USERNAME"):
		NAME.text = OS.get_environment("USERNAME")
	elif OS.has_environment("USER"):
		NAME.text = OS.get_environment("USER")
	else:
		NAME.text = "Player"
	
	Global.settings.name = NAME.text
	Global.saveSettings()
	
	Global.ingame = false
	FadeIn.visible = true
	Global.updateDiscordRPC()
	
	if Global.langameprocess != 0:
		OS.kill(Global.langameprocess)
	
	if Global.error != "":
		$CanvasLayer/Play/Error.text = Global.error
		Global.error = ""

func _on_Connect_pressed():
	Global.IP = IP.text
	Global.PORT = PORT.text
	Global.settings.name = NAME.text
	Global.saveSettings()
	get_tree().change_scene("res://scenes/game/Game.tscn")

var transparency = 1.0
func _process(delta):
	if FadeIn.visible == true and transparency > 0.0:
		transparency -= 0.005
		FadeIn.color = Color(0,0,0, transparency)
	elif transparency < 0.0:
		FadeIn.visible = false

func _input(event):
	if event.is_action_pressed("sendchat"):
		FadeIn.visible = false
		transparency = 0.0

func _on_Options_pressed():
	var options_menu = load("res://scenes/game/OptionsMenu.tscn").instance()
	$CanvasLayer.add_child(options_menu)
	#$CanvasLayer/OptionsMenu.connect("CloseOptionsMenu", self,("CloseOptionsMenu"))

func _on_About_pressed():
	var about_menu = load("res://scenes/game/AboutMenu.tscn").instance()
	$CanvasLayer.add_child(about_menu)

func _on_Exit_pressed():
	get_tree().quit()

func _on_Input_Name_text_changed(new_text):
	Global.settings.name = NAME.text
	Global.saveSettings()

func _on_StartLAN_pressed():
	Global.StartLANGame(NAME.text)

func _on_Button_Hover():
	$HoverSound.stop()
	$HoverSound.play()

