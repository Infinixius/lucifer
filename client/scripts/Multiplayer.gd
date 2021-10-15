extends Node

onready var player = $"../KinematicBody2D"
onready var chatbox = $"../CanvasLayer/Chat/Messages"
onready var messagebox = $"../CanvasLayer/Chat/Message"
onready var connectedtext = $"../CanvasLayer/Debug/connected_text"
onready var latencytext = $"../CanvasLayer/Debug/latency_text"


var id = 0 # our client's id, sent to us form the server with player_initalize
var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(Global.IP + ":" + Global.PORT)
	if err != OK:
		print("Unable to connect")
		latencytext.text = "Latency: Not Connected"
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto):
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Connected with protocol: " + proto)
	# you MUST always use get_peer(1).put_packet to send data to server, and not put_packet directly
	_client.get_peer(1).put_packet(JSON.print({
		"type": "player_connect"
	}).to_utf8())

func _on_data():
	# you MUST always use get_peer(1).get_packet to receive data from server, and not get_packet directly when not
	var json = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8())
	var data = json.result
	var msg = data.message
	
	if json.error == OK:
		if data.type == "player_connect":
			var player = Sprite.new()
			player.texture = load("res://assets/player_multiplayer.png")
			player.name = str(msg.id)
			self.add_child(player)
		elif data.type == "player_disconnect":
			var player = get_node(str(msg.id))
			player.queue_free()
		elif data.type == "player_move":
			var player = get_node(str(msg.id))
			player.position = player.get_global_position()
			player.position.x = msg.x
			player.position.y = msg.y
		elif data.type == "player_initalize":
			id = msg.id
			for plr in msg.players:
				var player = Sprite.new()
				player.texture = load("res://assets/player_multiplayer.png")
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
		old = live
	latencytext.text = "Latency: " + str(old) + " (" + str(live) + ")"

func movement_update(): # called in KinematicBody2D.gd to update position
	if _client.get_peer(1).is_connected_to_host():
		_client.get_peer(1).put_packet(JSON.print({
			"type": "player_move",
			"message": {
				"id": id,
				"x": player.position.x,
				"y": player.position.y
			}
		}).to_utf8())

func _process(delta):
	time += delta
	if !_client.get_peer(1).is_connected_to_host():
		connectedtext.text = "Not connected"
	else:
		connectedtext.text = "Connected to " + str(_client.get_peer(1).get_connected_host()) + ":" + str(_client.get_peer(1).get_connected_port())
	
	_client.poll()

func _on_Send_pressed(): # firedwhen the send message is pressed
	if _client.get_peer(1).is_connected_to_host():
		_client.get_peer(1).put_packet(JSON.print({
			"type": "send_message",
			"message": messagebox.text
		}).to_utf8())
		messagebox.text = ""
