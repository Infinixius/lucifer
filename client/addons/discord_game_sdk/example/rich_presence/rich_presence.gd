extends Node2D

func _ready():
	update_activity()
	create_lobby()
	
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("In the main menu")
	#activity.set_details("")

	var assets = activity.get_assets()
	assets.set_large_image("icon")
	assets.set_large_text("Lucifer")
	#assets.set_small_image("capsule_main")
	#assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(OS.get_unix_time() + 100)
	#timestamps.set_end(OS.get_unix_time() + 500)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))

func create_lobby():
	var transaction = Discord.lobby_manager.get_lobby_create_transaction()

	transaction.set_capacity(2)
	transaction.set_type(Discord.LobbyType.Private)
	transaction.set_locked(false)

	var result = yield(Discord.lobby_manager.create_lobby(transaction), "result")
	print(result)
	if result.result != Discord.Result.Ok:
		push_error(result.result)
		return

	var lobby = result.data
	#print(lobby)
	Discord.lobby_manager.send_lobby_message(lobby.get_id(), "hello people!")
