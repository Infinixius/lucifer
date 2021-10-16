extends Node2D

onready var body = $KinematicBody2D
onready var tile_map = $TileMap
onready var pos_text = $CanvasLayer/Debug/position_text
onready var rawpos_text = $CanvasLayer/Debug/rawposition_text
onready var fpstext = $CanvasLayer/Debug/fps_text

func _process(fl):
	# update the position text
	var pos = tile_map.world_to_map(body.position)
	var rawpos = body.position
	pos_text.text = "Tile X: " + str(floor(pos.x)) + " Y: " + str(floor(pos.y))
	rawpos_text.text = "Raw Position: X: " + str(floor(rawpos.x)) + " Y: " + str(floor(rawpos.y))
	fpstext.text =  "FPS: " + str(Engine.get_frames_per_second())


func _on_Exit_pressed():
	get_node("CanvasLayer/GameMenu").hide()
