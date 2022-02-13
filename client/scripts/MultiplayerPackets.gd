extends Node

onready var chatbox = $"../CanvasLayer/Chat/Messages"
onready var latencytext = $"../CanvasLayer/Debug/latency_text"
onready var player = $"../Player"

var id = 0

func processPacket(data, msg, id):
	if data.type == "player_connect":
		if msg.id != id: # we don't want to update ourselves
			var player = AnimatedSprite.new()
			player.scale = Vector2(2,2)
			player.frames = load("res://assets/data/animations/player_animations.res")
			player.name = str(msg.id)
			$"../Players".add_child(player)
	
	elif data.type == "player_disconnect":
		print(">>:: " + str(msg))
		var player = $"../Players".get_node(str(msg))
		player.queue_free() # delete the node
	
	elif data.type == "player_move":
		if !msg.id == id: # we don't want to update ourselves
			var plr = $"../Players".get_node(str(msg.id))
			if plr:
				plr.position = plr.get_global_position()
				plr.position.x = msg.x + 16
				plr.position.y = msg.y + 16
				plr.animation = msg.animation
				plr.frame = msg.animationframe
	
	elif data.type == "player_initalize":
		id = msg.id
		$"../Players".id = msg.id
		for plrl in msg.players:
			if plrl.id != id: # we don't want to update ourselves
				var plr = AnimatedSprite.new()
				plr.scale = Vector2(2,2)
				plr.frames = load("res://assets/data/animations/player_animations.res")
				plr.name = str(plrl.id)
				plr.position = plr.get_global_position()
				plr.position.x = plr.position[0]
				plr.position.y = plr.position[1]
				$"../Players".add_child(plr)
	
	elif data.type == "ping":
		latencytext.text = "Latency: " + str(data.timestamp - OS.get_unix_time())
	
	elif data.type == "receive_message":
		chatbox.text = chatbox.text + "\n[ " + msg.name + " ] " + msg.message
		chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
	
	elif data.type == "system_message":
		chatbox.text = chatbox.text + "\n" + msg
		chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
	
	elif data.type == "tile_update":
		$"../TileMap".set_cell(msg.x, msg.y, msg.tile)
	
	elif data.type == "tile_reset":
		$"../TileMap".clear()
	
	elif data.type == "player_update":
		if "hp" in msg:
			$"../CanvasLayer/HUD/HealthBar/TextureProgress".value = int(msg.hp)
		if "position" in msg:
			player.position = player.get_global_position()
			player.position.x = msg.position[0]
			player.position.y = msg.position[1]
	
	elif data.type == "entity_update":
		if msg.deleted == false:
			$"../Entities".spawnEntity(msg.type, msg.id, msg.position, msg.size, msg.rotation, msg.velocity)
		else:
			$"../Entities".deleteEntity(msg.id)
