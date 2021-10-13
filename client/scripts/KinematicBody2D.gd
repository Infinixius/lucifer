extends KinematicBody2D

export (int) var speed = 200

onready var tile_map = $"../TileMap"
onready var player = self
onready var Multiplayer = $"../Players"
onready var velocitytext = $"../CanvasLayer/Debug/velocity_text"

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
	if Input.is_action_pressed("debug"):
		$"../CanvasLayer/Debug".visible = !$"../CanvasLayer/Debug".visible
	
	velocity = velocity.normalized() * speed

var time = 0
func _physics_process(delta):
	time += delta
	get_input()
	velocity = move_and_slide(velocity, Vector2(0, -1))
	velocitytext.text = "Velocity: " + str(velocity)
	
	if velocity != Vector2(0,0): # loop every 0.015 seconds
		Multiplayer.movement_update()
		time = 0
