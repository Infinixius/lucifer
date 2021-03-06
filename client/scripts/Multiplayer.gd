extends Node

onready var player = $"../Player"
onready var playersprite = $"../Player/AnimatedSprite"
onready var connectedtext = $"../CanvasLayer/Debug/connected_text"

var id = 0 # our client's id, sent to us form the server with player_initalize
var iskicked = false
var client = WebSocketClient.new()

func _ready():
	client.connect("connection_closed", self, "closed")
	client.connect("connection_error", self, "closed")
	client.connect("connection_established", self, "connected")
	client.connect("data_received", self, "on_data")
	client.connect("server_close_request", self, "kicked")

	# Initiate connection to the given URL.
	var ip = Global.IP + ":" + Global.PORT + "/?username=" + Global.settings.name + "&version=" + Global.VERSION
	Console.write_line("SERVER: Attempting connection to " + str(ip))
	client.connect_to_url(ip)
	
	yield(get_tree().create_timer(5), "timeout")
	
	if id == 0:
		Console.write_line("SERVER: Failed to connect to " + str(ip) + "!")
		Global.error = "Can't connect"
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
		set_process(false)

func kicked(_code, reason):
	iskicked = true
	Console.write_line("SERVER: Kicked from server: " + str(reason))
	Global.error = "Kicked from server: " + str(reason)
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
	set_process(false)

func closed(_was_clean):
	if not iskicked:
		Console.write_line("SERVER: Connection closed!")
		Global.error = "Connection closed"
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
		set_process(false)

func connected(_proto):
	Console.write_line("SERVER: Connected!")
	Global.inserver = true
	movement_update()
	# you MUST always use get_peer(1).put_packet to send data to server, and not put_packet directly
	client.get_peer(1).put_packet(JSON.print({
		"type": "player_connect"
	}).to_utf8())

func on_data():
	# you MUST always use get_peer(1).get_packet to receive data from server, and not get_packet directly
	var raw = client.get_peer(1).get_packet().get_string_from_utf8()
	var json = JSON.parse(raw)
	var data = json.result
	if json.error == OK:
		if "message" in data:
			var msg = data.message
			$"../Packets".processPacket(data, msg, id)
		else:
			var msg = data[0]
			$"../Packets".processPacket(data, msg, id)
	else:
		print(json.error)
		print("Error Line: ", json.error_line)
		print("Error String: ", json.error_string)

func send(type, message):
	if client.get_peer(1).is_connected_to_host():
		client.get_peer(1).put_packet(JSON.print({
			"type": type,
			"message": message
		}).to_utf8())

func movement_update(): # called in Player.gd to update position
	send("player_move", {
		"x": floor(player.position.x),
		"y": floor(player.position.y),
		"animation": playersprite.animation,
		"animationframe": playersprite.frame
	})

func shoot(direction):
	var angle = 0
	angle = rad2deg(direction) - 90

	send("player_shoot", {
		"direction": angle
	})

var time = 0
func _process(delta):
	if !client.get_peer(1).is_connected_to_host():
		connectedtext.text = "Not connected"
	else:
		connectedtext.text = "Connected to " + str(client.get_peer(1).get_connected_host()) + ":" + str(client.get_peer(1).get_connected_port())
	
	time += delta
	if time > 1:
		time = 0
		send("clientping", delta)
	
	client.poll()

func shop(type, item):
	send("player_shop", {
		"type": type,
		"item": item
	})

func enemyAttack(type, enemyid):
	send("enemy_attack", {
		"type": type,
		"id": enemyid
	})
