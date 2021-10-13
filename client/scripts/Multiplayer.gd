extends Node

export var websocket_url = "ws://lucifer-ylp.herokuapp.com/" # url for the websocket server
onready var player = $"../KinematicBody2D"
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
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		latencytext.text = "Latency: Not Connected"
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
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
		#print("Got data from server: ", data)
		
		if data.type == "player_connect":
			var player = Sprite.new()
			player.texture = load("res://assets/player_multiplayer.png")
			player.name = str(msg.id)
			self.add_child(player)
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
				self.add_child(player)
		elif data.type == "ping":
			latencytext.text = "Latency: " + str((OS.get_system_time_msecs() - data.timestamp) - 1000)
	else:
		print(json.error)
		print("Error Line: ", json.error_line)
		print("Error String: ", json.error_string)

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
	if !_client.get_peer(1).is_connected_to_host():
		connectedtext.text = "Not connected"
	else:
		connectedtext.text = "Connected to " + str(_client.get_peer(1).get_connected_host()) + ":" + str(_client.get_peer(1).get_connected_port())
	
	_client.poll()
