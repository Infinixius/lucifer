extends Node

var Bullet = load("res://scenes/entities/Bullet.tscn")
onready var player = $"../Player"
onready var playersprite = $"../Player/AnimatedSprite"
onready var chatbox = $"../CanvasLayer/Chat/Messages"
onready var messagebox = $"../CanvasLayer/Chat/Message"
onready var connectedtext = $"../CanvasLayer/Debug/connected_text"
onready var latencytext = $"../CanvasLayer/Debug/latency_text"

var id = 0 # our client's id, sent to us form the server with player_initalize
var client = WebSocketClient.new()

func _ready():
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = client.connect_to_url(Global.IP + ":" + Global.PORT)
	
	yield(get_tree().create_timer(1), "timeout")
	
	if id == 0:
		Global.error = "Can't connect"
		get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
		set_process(false)

func _closed(was_clean):
	print("Closed, clean: ", was_clean)
	Global.error = "Connection closed"
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
	set_process(false)

func _connected(proto):
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Connected with protocol: " + proto)
	movement_update()
	# you MUST always use get_peer(1).put_packet to send data to server, and not put_packet directly
	client.get_peer(1).put_packet(JSON.print({
		"type": "player_connect"
	}).to_utf8())

func _on_data():
	# you MUST always use get_peer(1).get_packet to receive data from server, and not get_packet directly
	var raw = client.get_peer(1).get_packet().get_string_from_utf8()
	var json = JSON.parse(raw)
	var data = json.result
	var msg = data.message
	
	if json.error == OK:
		if data.type == "player_connect":
			if msg.id != id: # we don't want to update ourselves
				var player = AnimatedSprite.new()
				player.scale = Vector2(2,2)
				player.frames = load("res://assets/animations/player_animations.res")
				player.name = str(msg.id)
				self.add_child(player)
		elif data.type == "player_disconnect":
			var player = get_node(str(msg.id))
			player.queue_free() # delete the node
		elif data.type == "player_move":
			if !msg.id == id: # we don't want to update ourselves
				var player = get_node(str(msg.id))
				player.position = player.get_global_position()
				player.position.x = msg.x + 16
				player.position.y = msg.y + 16
				player.animation = msg.animation
				player.frame = msg.animationframe
		elif data.type == "player_initalize":
			id = msg.id
			for plr in msg.players:
				if plr.id != id: # we don't want to update ourselves
					var player = AnimatedSprite.new()
					player.scale = Vector2(2,2)
					player.frames = load("res://assets/animations/player_animations.res")
					player.name = str(plr.id)
					player.position = player.get_global_position()
					player.position.x = plr.position[0]
					player.position.y = plr.position[1]
					self.add_child(player)
		elif data.type == "ping":
			latency_update(data.timestamp)
		elif data.type == "receive_message":
			chatbox.text = chatbox.text + "\n[ " + msg.name + " ] " + msg.message
			chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
		elif data.type == "system_message":
			chatbox.text = chatbox.text + "\n" + msg
			chatbox.scroll_to_line(chatbox.text.count("\n", 0, 0)) # count gets the amount of lines, to scroll to the bottom
		elif data.type == "tile_update":
			$"../TileMap".set_cell(msg.x, msg.y, msg.tile)
		elif data.type == "player_update":
			if msg.hp:
				$"../CanvasLayer/HUD/HealthBar/TextureProgress".value = msg.hp
		elif data.type == "player_shoot":
			var b = Bullet.instance()
			owner.add_child(b)
			b.position = b.get_global_position()
			b.position.x = msg.position[0] + 16 # offset by 16
			b.position.y = msg.position[1] + 16 # offset by 16
			b.rotation_degrees = msg.rotation
	else:
		print(json.error)
		print("Error Line: ", json.error_line)
		print("Error String: ", json.error_string)

var time = 0
var old = 0
func latency_update(timestamp): # called to update latency text
	var live = OS.get_system_time_msecs() - timestamp # live latency
	if time > 1:
		time = 0
		old = live # old latency, only updated every second using a timer from var old, which is updated in _process()
	latencytext.text = "Latency: " + str(old) + " (" + str(live) + ")"

func movement_update(): # called in KinematicBody2D.gd to update position
	if client.get_peer(1).is_connected_to_host():
		client.get_peer(1).put_packet(JSON.print({
			"type": "player_move",
			"message": {
				"x": floor(player.position.x),
				"y": floor(player.position.y),
				"animation": playersprite.animation,
				"animationframe": playersprite.frame
			}
		}).to_utf8())

func shoot(direction):
	var angle = 0
	angle = rad2deg(direction) - 90
	if client.get_peer(1).is_connected_to_host():
		client.get_peer(1).put_packet(JSON.print({
			"type": "player_shoot",
			"message": {
				"direction": angle
			}
		}).to_utf8())

func sendChatMessage():
	if client.get_peer(1).is_connected_to_host():
		client.get_peer(1).put_packet(JSON.print({
			"type": "send_message",
			"message": messagebox.text
		}).to_utf8())
		messagebox.text = ""

func _process(delta):
	time += delta
	if !client.get_peer(1).is_connected_to_host():
		connectedtext.text = "Not connected"
	else:
		connectedtext.text = "Connected to " + str(client.get_peer(1).get_connected_host()) + ":" + str(client.get_peer(1).get_connected_port())
	
	client.poll()
	
	


func _on_Send_pressed(): # firedwhen the send message is pressed
	sendChatMessage()
