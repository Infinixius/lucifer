extends Node

onready var bus = AudioServer.get_bus_index("Master")

var firstLaunch = true
var IP = "localhost"
var PORT = "8000"
var VERSION = "1.2"
var error = ""
var ingame = false
var inserver = false
var isplaying = true
var isdead = false
var deathreason = ""
var deathscore = 0
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
	"fpscap": 60
}

func _ready():
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
		
		AudioServer.set_bus_volume_db(bus, linear2db(settings.volume))
	else:
		print("Failed to load data! Error: " + str(err))

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

func StartLANGame(name):
	match OS.get_name():
		"Windows", "UWP":
			Global.langameprocess = OS.execute("./lan/windows.exe", ["--langame"], false)
		"macOS":
			Global.langameprocess = OS.execute("./lan/mac", ["--langame"], false)
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			Global.langameprocess = OS.execute("./lan/linux", ["--langame"], false)

	Global.IP = "http://localhost"
	Global.PORT = "6666"
	Global.settings.name = name
	Global.saveSettings()
	get_tree().change_scene("res://scenes/game/Game.tscn")

func change_scene_async(path):
	var gamescene = load(path)
	get_tree().call_deferred("change_scene_to", gamescene)

func loadSceneAsync(path):
	var thread = Thread.new()
	thread.start(self, "change_scene_async", path)
	
