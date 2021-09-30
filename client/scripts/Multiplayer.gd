extends Node2D

export var websocket_url = "ws://localhost:3939"

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
	_client.get_peer(1).put_packet("Test packet".to_utf8())

#func _on_data():
	# you MUST always use get_peer(1).get_packet to receive data from server, and not get_packet directly when not
	#var data = {}
	#data.parse_json(_client.get_peer(1).get_packet().get_string_from_utf8())
	#print("Got data from server: ", data)

func _process(delta):
	_client.poll()
