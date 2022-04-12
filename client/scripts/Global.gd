extends Node

onready var bus = AudioServer.get_bus_index("Master")

var firstLaunch = true
var IP = "localhost"
var PORT = "8000"
var VERSION = "1.3.1"
var error = ""
var ingame = false
var inserver = false
var isplaying = true
var isdead = false
var deathreason = ""
var deathscore = 0
var cheats = false
var pathfinding
var id = 0
var langameprocess = 0
var discordActivity
var settingsFile = ConfigFile.new()
var settings = {
	"noclip": false,
	"lighting": true,
	"discord": false,
	"devOptions": false,
	"silent": false,
	"tickRate": 0.25,
	"fullscreen": false,
	"name": "",
	"volume": 0.5,
	"fpscap": 60,
	"vsync": true
}

func _ready():
	OS.center_window()
	OS.set_window_maximized(true)
	var err = settingsFile.load("user://settings.cfg")

	if err == OK:
		settings.noclip = settingsFile.get_value("settings", "noclip", false)
		settings.lighting = settingsFile.get_value("settings", "lighting", true)
		settings.discord = settingsFile.get_value("settings", "discord", true)
		settings.devOptions = settingsFile.get_value("settings", "devOptions", false)
		settings.silent = settingsFile.get_value("settings", "silent", false)
		settings.tickRate = settingsFile.get_value("settings", "tickRate", 0.25)
		settings.fullscreen = settingsFile.get_value("settings", "fullscreen", false)
		settings.name = settingsFile.get_value("settings", "name", "Default")
		settings.volume = settingsFile.get_value("settings", "volume", 0.5)
		settings.fpscap = settingsFile.get_value("settings", "fpscap", 60)
		settings.vsync = settingsFile.get_value("settings", "vsync", true)
		
		AudioServer.set_bus_volume_db(bus, linear2db(settings.volume))
		Engine.set_target_fps(settings.fpscap)
		OS.set_use_vsync(settings.vsync)
	else:
		print("Failed to load data! Error: " + str(err))
	
	Console.add_command("eval", self, "command_eval")\
		.set_description("Evaluates GDScript code. WARNING: Any errors caused by code you eval WILL crash the game!")\
		.add_argument("code", TYPE_STRING)\
		.register()

func _input(event):
	if event.is_action_pressed("fullscreen"):
		settings.fullscreen = !settings.fullscreen
		saveSettings()

func _process(_delta):
	OS.window_fullscreen = settings.fullscreen

func saveSettings():
	settingsFile.set_value("settings", "noclip", settings.noclip)
	settingsFile.set_value("settings", "lighting", settings.lighting)
	settingsFile.set_value("settings", "discord", settings.discord)
	settingsFile.set_value("settings", "devOptions", settings.devOptions)
	settingsFile.set_value("settings", "silent", settings.silent)
	settingsFile.set_value("settings", "tickRate", settings.tickRate)
	settingsFile.set_value("settings", "fullscreen", settings.fullscreen)
	settingsFile.set_value("settings", "name", settings.name)
	settingsFile.set_value("settings", "volume", settings.volume)
	settingsFile.set_value("settings", "fpscap", settings.fpscap)
	settingsFile.set_value("settings", "vsync", settings.vsync)
	
	var err = settingsFile.save("user://settings.cfg")
	
	if err != OK:
		print("Failed to save data! Error: " + str(err))

func updateDiscordRPC():
	if settings.discord == true:
		discordActivity = Discord.Activity.new()
		discordActivity.set_type(Discord.ActivityType.Playing)
		if ingame == true:
			discordActivity.set_state("In a game")
		else:
			discordActivity.set_state("In the main menu")
		
		var assets = discordActivity.get_assets()
		assets.set_large_image("icon")
		assets.set_large_text("Lucifer")
		
		if Discord.activity_manager != null:
			var result = yield(Discord.activity_manager.update_activity(discordActivity), "result").result
			if result != Discord.Result.Ok:
				print("Failed to set Discord RPC! Error: " + str(result))
	elif Discord.activity_manager:
		var result = Discord.activity_manager.clear_activity()
		
		if result.result != Discord.Result.Ok:
			print("Failed to set Discord RPC! Error: " + str(result))

func StartLANGame(cheatsenabled):
	var options = ["--langame"]
	if cheatsenabled:
		options.append("--cheats")
	
	match OS.get_name():
		"Windows", "UWP":
			Global.langameprocess = OS.execute("./lan/lucifer-ylp-win.exe", options, false)
		"macOS":
			Global.langameprocess = OS.execute("./lan/lucifer-ylp-macos", options, false)
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			Global.langameprocess = OS.execute("./lan/lucifer-ylp-linux", options, false)
	
	if Global.langameprocess == -1:
		OS.alert("Failed to start LAN game! The Node.JS executable is likely missing or corrupted.", "Node.JS Executable Error")
	else:
		Global.IP = "http://localhost"
		Global.PORT = "6666"
		Global.saveSettings()
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/game/Game.tscn")

func SearchForLANGames():
	var output = []
	var exitCode
	
	match OS.get_name():
		"Windows", "UWP":
			exitCode = OS.execute("./lan/lucifer-ylp-win.exe", ["--scan"], true, output)
		"macOS":
			exitCode = OS.execute("./lan/lucifer-ylp-macos", ["--scan"], true, output)
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			exitCode = OS.execute("./lan/lucifer-ylp-linux", ["--scan"], true, output)
	
	if exitCode != 0:
		OS.alert("Failed to get LAN games! The Node.JS executable is likely missing or corrupted.", "Node.JS Executable Error")
		return []
	else:
		if output[0].trim_suffix("\r").trim_suffix("\n") == "\n":
			return []
		return output

func command_eval(code):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + code)
	script.reload()

	var obj = Reference.new()
	obj.set_script(script)

	Console.write_line(obj.eval())
	print(obj.eval())