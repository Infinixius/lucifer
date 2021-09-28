extends KinematicBody2D

export (int) var speed = 200

onready var tile_map = $"../TileMap"
onready var player = self

var velocity = Vector2()
var speedvel = 1000

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += speedvel
	if Input.is_action_pressed("left"):
		velocity.x -= speedvel
	if Input.is_action_pressed("down"):
		velocity.y += speedvel
	if Input.is_action_pressed("up"):
		velocity.y -= speedvel
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity, Vector2(0, -1))
