extends Node

var IP = "localhost"
var PORT = "8000"
var VERSION = "0.7"
var VERSIONNUM = 22
var error = ""
var ingame = false
var discordActivity
var settings = {
	"noclip": false,
	"lighting": true,
	"discord": false,
	"devOptions": false,
}

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
		
		var result = yield(Discord.activity_manager.update_activity(discordActivity), "result").result
		if result != Discord.Result.Ok:
			print("Failed to set Discord RPC! Error: " + str(result))
	else:
		var result = Discord.activity_manager.clear_activity()
		
		if result.result != Discord.Result.Ok:
			print("Failed to set Discord RPC! Error: " + str(result))
