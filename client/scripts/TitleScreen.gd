extends Node2D

onready var IP = $CanvasLayer/Play/Input_IP
onready var PORT = $CanvasLayer/Play/Input_Port
onready var NAME = $CanvasLayer/Play/Input_Name
onready var FadeIn = $CanvasLayer/FadeIn
var StartLANGame = load("res://scenes/game/StartLANGame.tscn")
var SearchForLANGames = load("res://scenes/game/SearchForLANGames.tscn")

var fading = false

func _ready():
	if Global.settings.analytics and Global.firstLaunch:
		sendAnalyticsRequest()
	elif Global.firstLaunch:
		$CanvasLayer/VideoPlayer.play()
	
	if str(OS.get_cmdline_args()).find("-deez") != -1:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/game/deez.tscn")
		
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
		# warning-ignore:return_value_discarded
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
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game/Game.tscn")

var transparency = 1.0
func _process(_delta):
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

func _on_Input_Name_text_changed(_new_text):
	Global.settings.name = NAME.text
	Global.saveSettings()

func _on_StartLAN_pressed():
	Global.settings.name = NAME.text
	var startlangame = StartLANGame.instance()
	$"/root/TitleScreen/CanvasLayer".add_child(startlangame)

func _on_Button_Hover():
	$HoverSound.stop()
	$HoverSound.play()

func _on_SearchLAN_pressed():
	var searchforlangames = SearchForLANGames.instance()
	$"/root/TitleScreen/CanvasLayer".add_child(searchforlangames)

func sendAnalyticsRequest():
	var lang = str(OS.get_locale()).http_escape()
	var os = str(OS.get_name()).http_escape()
	var cpu = str(OS.get_processor_count()).http_escape()
	var gpu = str(VisualServer.get_video_adapter_name()).http_escape()
	var monitor = OS.get_real_window_size()
	var boot = str(OS.get_splash_tick_msec()).http_escape()

	var string = Global.analyticsURL + "/?lang=" + lang + "&os=" + os + "&cpu=" + cpu + "&gpu=" + gpu + "&monitorx=" + str(monitor.x) + "&monitory=" + str(monitor.y) + "&boot=" + boot + "&version=" + Global.VERSION
	var req = $HTTPRequest.request(string)

	yield($HTTPRequest, "request_completed")
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if not Global.firstLaunch:
		$CanvasLayer/VideoPlayer.play()
	
	var vers = JSON.parse(body.get_string_from_utf8()).result
	
	if !vers:
		Console.write_line("Failed to check for updates")
	else:
		if not vers == Global.VERSION:
			OS.alert("You're on an outdated version! The latest version is v" + vers + ", and you're on v" + Global.VERSION + "!\nYou can get the latest version at https://lucifer.games.", "Outdated Version")
