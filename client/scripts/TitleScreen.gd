extends Node2D

onready var IP = $CanvasLayer/Play/Input_IP
onready var PORT = $CanvasLayer/Play/Input_Port
onready var NAME = $CanvasLayer/Play/Input_Name
onready var FadeIn = $CanvasLayer/FadeIn

var fading = false

func _ready():
	$CanvasLayer/VideoPlayer.visible = true # hidden in the editor
	$CanvasLayer/VideoPlayerBackground.visible = true
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
	Global.isdead = false
	Global.inserver = false
	FadeIn.visible = true
	Global.updateDiscordRPC()
	
	if Global.langameprocess != 0:
		OS.kill(Global.langameprocess)
	
	if Global.error != "":
		$CanvasLayer/Play/Error.text = Global.error
		Global.error = ""
	
	if Global.firstLaunch == true:
		yield(get_tree().create_timer(16), "timeout")
		$CanvasLayer/VideoPlayer.queue_free()
		$CanvasLayer/VideoPlayerBackground.queue_free()
		fading = true
		Global.firstLaunch = false
	else:
		fading = true
		$CanvasLayer/VideoPlayer.queue_free()
		$CanvasLayer/VideoPlayerBackground.queue_free()

func _on_Connect_pressed():
	Global.IP = IP.text
	Global.PORT = PORT.text
	Global.settings.name = NAME.text
	Global.saveSettings()
	get_tree().change_scene("res://scenes/game/Game.tscn")

var transparency = 1.0
func _process(delta):
	if fading:
		if FadeIn.visible == true and transparency > 0.0:
			transparency -= 0.005
			FadeIn.color = Color(0,0,0, transparency)
		elif transparency < 0.0:
			FadeIn.visible = false

func _input(event):
	if event.is_action_pressed("sendchat") or event.is_action_pressed("GameMenu"):
		FadeIn.visible = false
		transparency = 0.0
		if get_node_or_null("CanvasLayer/VideoPlayer"):
			$CanvasLayer/VideoPlayer.visible = false
			$CanvasLayer/VideoPlayerBackground.visible = false
		Global.firstLaunch = false

func _on_Options_pressed():
	var options_menu = load("res://scenes/game/OptionsMenu.tscn").instance()
	$CanvasLayer.add_child(options_menu)

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

