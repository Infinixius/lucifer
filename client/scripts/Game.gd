extends Node2D

onready var body = $KinematicBody2D
onready var tile_map = $TileMap
onready var pos_text = $CanvasLayer/position_text
onready var rawpos_text = $CanvasLayer/rawposition_text

# game state

var player_tile
var score = 0

# Called when the node enters the scene tree for the first time.
#func _ready():

func _process(fl):
	var pos = tile_map.world_to_map(body.position)
	var rawpos = body.position
	pos_text.text = "Tile X: " + str(floor(pos.x)) + " Y: " + str(floor(pos.y))
	rawpos_text.text = "Raw Position: X: " + str(floor(rawpos.x)) + " Y: " + str(floor(rawpos.y))
