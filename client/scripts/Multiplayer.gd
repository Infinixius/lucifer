extends Node

onready var player = $"../Player"
onready var playersprite = $"../Player/AnimatedSprite"
onready var messagebox = $"../CanvasLayer/Chat/Message"
onready var connectedtext = $"../CanvasLayer/Debug/connected_text"

var id = 0 # our client's id, sent to us form the server with player_initalize
var client = WebSocketClient.new()

func _ready():
	client.connect("connection_closed", self, "closed")
	client.connect("connection_error", self, "closed")
	client.connect("connection_established", self, "connected")
	client.connect("data_received", self, "on_data")

	# Initiate connection to the given URL.
	var err = client.connect_to_url(Global.IP + ":" + Global.PORT)
	
	yield(get_tree().create_timer(1), "timeout")
	
	if id == 0:
		Global.error = "Can't connect"
		get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
		set_process(false)

func closed(was_clean):
	print("Closed, clean: ", was_clean)
	Global.error = "Connection closed"
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
	set_process(false)

func connected(proto):
	print("Connected to server!")
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
	var msg = data.message
	
	if json.error == OK:
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

func sendChatMessage():
	send("send_message", messagebox.text)
	messagebox.text = ""

func _process(delta):
	if !client.get_peer(1).is_connected_to_host():
		connectedtext.text = "Not connected"
	else:
		connectedtext.text = "Connected to " + str(client.get_peer(1).get_connected_host()) + ":" + str(client.get_peer(1).get_connected_port())
	
	client.poll()

func _on_Send_pressed(): # firedwhen the send message is pressed
	sendChatMessage()
