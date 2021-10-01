extends Node

export var websocket_url = "ws://localhost:3939"
onready var player = $"../KinematicBody2D"

var id = 0
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
	
	if json.error == OK:
		print("Got data from server: ", data)
		
		if data.type == "player_connect":
			var player = Sprite.new()
			player.texture = load("res://assets/player_multiplayer.png")
			player.name = str(data.id)
			self.add_child(player)
		elif data.type == "player_move":
			var player = get_node(str(data.id))
			player.position = player.get_global_position()
			player.position.x = data.x
			player.position.y = data.y
		elif data.type == "player_initalize":
			id = data.id
			for x in data.players:
				var player = Sprite.new()
				player.texture = load("res://assets/player_multiplayer.png")
				player.name = str(x)
				self.add_child(player)
	else:
		print(json.error)
		print("Error Line: ", json.error_line)
		print("Error String: ", json.error_string)

func movement_update(): # called in KinematicBody2D.gd to update position
	_client.get_peer(1).put_packet(JSON.print({
		"type": "player_move",
		"id": id,
		"x": player.position.x,
		"y": player.position.y
	}).to_utf8())

func _process(delta):
	_client.poll()
