extends Node2D

onready var body = $Player
onready var tile_map = $Navigation2D/TileMap
onready var pos_text = $CanvasLayer/Debug/position_text
onready var rawpos_text = $CanvasLayer/Debug/rawposition_text
onready var fpstext = $CanvasLayer/HUD/FPS

func _ready():
	$CanvasLayer/Vignette.visible = true # the vignette is disabled in the editor to make it easier to see things, this enables it in the game.
	$CanvasLayer/Loading.visible = true # same as above
	Global.ingame = true
	Global.updateDiscordRPC()

func _process(_delta):
	# update the position text
	var pos = tile_map.world_to_map(body.position)
	var rawpos = body.position
	pos_text.text = "Tile X: " + str(floor(pos.x)) + " Y: " + str(floor(pos.y))
	rawpos_text.text = "Raw Position: X: " + str(floor(rawpos.x)) + " Y: " + str(floor(rawpos.y))
	fpstext.text =  "FPS: " + str(Engine.get_frames_per_second())

func _on_Resume_pressed():
	get_node("CanvasLayer/GameMenu").visible = false

var code = []
var konamiCode = ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A"]
func handleKey(event):
	if konamiCode.has(OS.get_scancode_string(event.physical_scancode)):
		code.append(OS.get_scancode_string(event.physical_scancode))
		if code.size() > 10:
			code.pop_front()
	else:
		code.clear()
	
	if code == konamiCode:
		$"/root/Game/Players".send("konami", true)
		$"/root/Game/Sounds".play("Konami")

func _input(event):
	if event.get_class() == "InputEventKey":
		if event.pressed and Global.ingame and Global.inserver and not Global.isdead:
			handleKey(event)
	
	if event.is_action_pressed("GameMenu") and not Global.inserver:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
	if event.is_action_pressed("upgrade") and not get_node_or_null("CanvasLayer/UpgradesMenu")  and not Global.isdead:
		var upgrades_menu = load("res://scenes/game/UpgradeMenu.tscn").instance()
		$CanvasLayer.add_child(upgrades_menu)
