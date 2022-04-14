extends Node

onready var chatbox = $"../CanvasLayer/Chat/Messages"
onready var latencytext = $"../CanvasLayer/Debug/latency_text"
onready var player = $"../Player"
var NetworkPlayer = load("res://scenes/entities/NetworkPlayer.tscn")
var Torch = load("res://scenes/entities/Torch.tscn")
var Exit = load("res://scenes/entities/Exit.tscn")

var id = 0

func processPacket(data, msg, id):
	if data.type == "player_connect":
		if msg.id != id: # we don't want to update ourselves
			var plr = NetworkPlayer.instance()
			plr.name = str(msg.id)
			plr.get_node("AnimatedSprite").get_node("Node2D").get_node("Name").text = str(msg.name)
			$"../Players".add_child(plr)
	
	elif data.type == "player_disconnect":
		var plr = $"../Players".get_node(str(msg))
		plr.queue_free() # delete the node
	
	elif data.type == "player_move":
		if !msg.id == id: # we don't want to update ourselves
			var plr = $"../Players".get_node_or_null(str(msg.id))
			if plr:
				plr.position = Vector2(msg.x, msg.y)

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
		Console.write_line("CHAT MESSAGE: " + " [ " + msg.name + " ] " + msg.message)
		chatbox.text = chatbox.text + "\n[ " + msg.name + " ] " + msg.message
		chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
	
	elif data.type == "system_message":
		Console.write_line("SYSTEM MESSAGE: " + str(msg))
		chatbox.text = chatbox.text + "\n" + msg
		chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
	
	elif data.type == "tile_update":
		$"../Navigation2D/TileMap".set_cell(msg.x, msg.y, msg.tile)
		if msg.tile >= 14 and msg.tile <= 17:
			var torch = Torch.instance()
			torch.position = $"../Navigation2D/TileMap".to_global($"../Navigation2D/TileMap".map_to_world(Vector2(msg.x, msg.y)))
			if msg.tile == 14:
				torch.position += Vector2(16, 28)
			elif msg.tile == 15:
				torch.position += Vector2(6, 16)
			elif msg.tile == 16:
				torch.position += Vector2(28, 16)
			elif msg.tile == 17:
				torch.position += Vector2(16, 6)
			$"../Navigation2D/TileMap".add_child(torch)
		elif msg.tile == 18:
			var exit = Exit.instance()
			exit.position = $"../Navigation2D/TileMap".to_global($"../Navigation2D/TileMap".map_to_world(Vector2(msg.x, msg.y))) + Vector2(16, 16)
			$"../Navigation2D/TileMap".add_child(exit)
	
	elif data.type == "tile_update_chunk":
		for tile in msg.tiles:
			$"../Navigation2D/TileMap".set_cell(tile.x, tile.y, tile.tile)
	
	elif data.type == "tile_reset":
		$"../Navigation2D/TileMap".clear()
	
	elif data.type == "tile_update_done":
		$"../CanvasLayer/Loading".visible = false
		$"../Navigation2D/TileMap".update_dirty_quadrants()
		Global.isdead = false
		
		var tween = $"../Player/AnimatedSprite/Camera2D/Tween"
		tween.interpolate_property($"../Player/AnimatedSprite/Camera2D", "zoom",
				Vector2(20, 20), Vector2(0.6, 0.6), 1,
				Tween.TRANS_QUART, Tween.EASE_IN)
		tween.start()
		
	
	elif data.type == "newlevel":
		Global.isdead = true
		for entity in $"../Entities".get_children():
			entity.queue_free()
		for mapentity in $"../Navigation2D/TileMap".get_children():
			mapentity.queue_free()
		
		$"../Navigation2D/TileMap".clear()
		
		var tween = $"../Player/AnimatedSprite/Camera2D/Tween"
		tween.interpolate_property($"../Player/AnimatedSprite/Camera2D", "zoom",
				Vector2(0.6, 0.6), Vector2(20, 20), 2,
				Tween.TRANS_QUART, Tween.EASE_IN)
		tween.start()
	
	elif data.type == "player_update":
		if "hp" in msg:
			$"../CanvasLayer/HUD/HealthBar/TextureProgress".value = int(msg.hp)
			$"../CanvasLayer/HUD/HealthBar/TextureProgress/Number".text = "HP: " + str(msg.hp) + "/" + str(msg.maxhp)
		if "maxhp" in msg:
			$"../CanvasLayer/HUD/HealthBar/TextureProgress".max_value = int(msg.maxhp)
		if "coins" in msg:
			$"../CanvasLayer/HUD/Stats/Coins".text = "Coins: " + str(msg.coins)
			if get_node_or_null("../CanvasLayer/UpgradesMenu"):
				$"../CanvasLayer/UpgradesMenu/Coins".text = "Coins: " + str(msg.coins)
		if "kills" in msg:
			$"../CanvasLayer/HUD/Stats/Kills".text = "Enemies Killed: " + str(msg.kills)
		if "remaining" in msg:
			$"../CanvasLayer/HUD/Stats/Enemies".text = "Enemies Left: " + str(msg.remaining)
		
		if "level" in msg:
			$"../CanvasLayer/HUD/Level".text = "Level: " + str(msg.level)
		if "cheats" in msg:
			Global.cheats = bool(msg.cheats)
		
		if "upgrades" in msg:
			if get_node_or_null("../CanvasLayer/UpgradesMenu"):
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Health/TextureProgress".value = int(msg.upgrades.skills.health)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Strength/TextureProgress".value = int(msg.upgrades.skills.strength)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Speed/TextureProgress".value = int(msg.upgrades.skills.speed)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Luck/TextureProgress".value = int(msg.upgrades.skills.luck)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Reload/TextureProgress".value = int(msg.upgrades.skills.reload)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/BulletSpeed/TextureProgress".value = int(msg.upgrades.skills.bulletspeed)
				
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Piercing/TextureProgress".value = int(msg.upgrades.abilities.piercing)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Regeneration/TextureProgress".value = int(msg.upgrades.abilities.regeneration)
				$"../CanvasLayer/UpgradesMenu/ScrollContainer/Main/Rejuvenation/TextureProgress".value = int(msg.upgrades.abilities.rejuvenation)
				
				$"../Player".speed = 500 + (25 * int(msg.upgrades.skills.speed))
		if "position" in msg:
			player.position = player.get_global_position()
			player.position.x = msg.position[0]
			player.position.y = msg.position[1]
	
	elif data.type == "entity_update":
		if msg.deleted == false:
			$"../Entities".spawnEntity(msg.type, msg.id, msg.position, msg.size, msg.rotation, msg.velocity, msg)
		else:
			$"../Entities".deleteEntity(msg.id)
	elif data.type == "shop_success":
		$"../Sounds".play("Upgrade")
	elif data.type == "enemy_hurt":
		var enemy = $"../Entities".get_node_or_null(str(msg))
		if enemy:
			enemy.get_node("Enemy").get_node("Sprite").modulate = Color(1,0,0,1)
	elif data.type == "player_kill":
		if msg.id == id:
			Global.isdead = true
			Global.deathreason = msg.reason
			player.died()
	elif data.type == "player_respawn":
		if msg.id == id:
			Global.isdead = false
			Global.deathreason = ""
