extends Node2D

onready var body = $Player
onready var tile_map = $TileMap
onready var pos_text = $CanvasLayer/Debug/position_text
onready var rawpos_text = $CanvasLayer/Debug/rawposition_text
onready var fpstext = $CanvasLayer/Debug/fps_text

func _ready():
	$CanvasLayer/Vignette.visible = true # the vignette is disabled in the editor to make it easier to see things, this enables it in the game.
	update_activity()

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("In a game")
	
	var assets = activity.get_assets()
	assets.set_large_image("icon")
	assets.set_large_text("Lucifer")
	
	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))

func _process(_delta):
	# update the position text
	var pos = tile_map.world_to_map(body.position)
	var rawpos = body.position
	pos_text.text = "Tile X: " + str(floor(pos.x)) + " Y: " + str(floor(pos.y))
	rawpos_text.text = "Raw Position: X: " + str(floor(rawpos.x)) + " Y: " + str(floor(rawpos.y))
	fpstext.text =  "FPS: " + str(Engine.get_frames_per_second())

func _on_Resume_pressed():
	get_node("CanvasLayer/GameMenu").visible = false

func _input(event):
	if event.is_action_pressed("chat"):
		$CanvasLayer/Chat/Message.grab_focus()
	if event.is_action_pressed("sendchat"):
		$Players.sendChatMessage()
