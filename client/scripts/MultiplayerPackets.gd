extends Node

onready var chatbox = $"../CanvasLayer/Chat/Messages"
onready var latencytext = $"../CanvasLayer/Debug/latency_text"
onready var player = $"../Player"
var NetworkPlayer = load("res://scenes/entities/NetworkPlayer.tscn")

var id = 0

func processPacket(data, msg, id):
	if data.type == "player_connect":
		if msg.id != id: # we don't want to update ourselves
			var plr = NetworkPlayer.instance()
			plr.name = str(msg.id)
			plr.get_node("AnimatedSprite").get_node("Name").text = str(msg.name)
			$"../Players".add_child(plr)
	
	elif data.type == "player_disconnect":
		var plr = $"../Players".get_node(str(msg))
		plr.queue_free() # delete the node
	
	elif data.type == "player_move":
		if !msg.id == id: # we don't want to update ourselves
			var plr = $"../Players".get_node_or_null(str(msg.id))
			if plr:
				plr.position = Vector2(msg.x + 16, msg.y + 16)
				plr.get_node("AnimatedSprite").animation = msg.animation
				plr.get_node("AnimatedSprite").frame = msg.animationframe
	
	elif data.type == "player_initalize":
		id = msg.id
		Global.id = msg.id
		$"../Players".id = msg.id
		for plrl in msg.players:
			if plrl.id != id: # we don't want to update ourselves
				var plr = NetworkPlayer.instance()
				plr.name = str(plrl.id)
				plr.get_node("AnimatedSprite").get_node("Name").text = str(plrl.name)
				plr.position = Vector2(plrl.position[0], plrl.position[1])
				$"../Players".add_child(plr)
	
	elif data.type == "ping":
		latencytext.text = "Latency: " + str(OS.get_system_time_msecs() - data.timestamp)
	
	elif data.type == "receive_message":
		chatbox.text = chatbox.text + "\n[ " + msg.name + " ] " + msg.message
		chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
	
	elif data.type == "system_message":
		chatbox.text = chatbox.text + "\n" + msg
		chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
	
	elif data.type == "tile_update":
		$"../TileMap".set_cell(msg.x, msg.y, msg.tile)
	
	elif data.type == "tile_update_chunk":
		for tile in msg.tiles:
			$"../TileMap".set_cell(tile.x, tile.y, tile.tile)
	
	elif data.type == "tile_reset":
		$"../TileMap".clear()
	
	elif data.type == "tile_update_done":
		$"../CanvasLayer/Loading".visible = false
		var tween = $"../Player/AnimatedSprite/Camera2D/Tween"
		tween.interpolate_property($"../Player/AnimatedSprite/Camera2D", "zoom",
				Vector2(20, 20), Vector2(0.6, 0.6), 1,
				Tween.TRANS_QUART, Tween.EASE_IN)
		tween.start()
	
	elif data.type == "player_update":
		if "hp" in msg:
			$"../CanvasLayer/HUD/HealthBar/TextureProgress".value = int(msg.hp)
		if "maxhp" in msg:
			$"../CanvasLayer/HUD/HealthBar/TextureProgress".max_value = int(msg.maxhp)
		if "coins" in msg:
			$"../CanvasLayer/HUD/Stats/Coins".text = "Coins: " + str(msg.coins)
		if "kills" in msg:
			$"../CanvasLayer/HUD/Stats/Kills".text = "Enemies Killed: " + str(msg.kills)
		if "remaining" in msg:
			$"../CanvasLayer/HUD/Stats/Enemies".text = "Enemies Left: " + str(msg.remaining)
		
		if "position" in msg:
			player.position = player.get_global_position()
			player.position.x = msg.position[0]
			player.position.y = msg.position[1]
	
	elif data.type == "entity_update":
		if msg.deleted == false:
			$"../Entities".spawnEntity(msg.type, msg.id, msg.position, msg.size, msg.rotation, msg.velocity, msg)
		else:
			$"../Entities".deleteEntity(msg.id)
