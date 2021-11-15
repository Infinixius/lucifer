extends KinematicBody2D

export (int) var speed = 350

onready var sprite = $AnimatedSprite

onready var tile_map = $"../TileMap"
onready var player = self
onready var Multiplayer = $"../Players"
onready var velocitytext = $"../CanvasLayer/Debug/velocity_text"
onready var bulletspawn = $BulletSpawn

var velocity = Vector2()
var speedvel = 1000
var direction = "right"

func get_input():
	velocity = Vector2()
	#bulletspawn.position = bulletspawn.get_global_position()
	if Input.is_action_pressed("right"):
		velocity.x += speedvel
		direction = "right"
		
		bulletspawn.position.x = 32
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 0
	if Input.is_action_pressed("left"):
		velocity.x -= speedvel
		direction = "left"
		
		bulletspawn.position.x = 0
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 180
	if Input.is_action_pressed("down"):
		velocity.y += speedvel
		direction = "down"
		
		bulletspawn.position.x = 16
		bulletspawn.position.y = 32
		bulletspawn.rotation_degrees = 90
	if Input.is_action_pressed("up"):
		velocity.y -= speedvel
		direction = "up"
		
		bulletspawn.position.x = 16
		bulletspawn.position.y = 0
		bulletspawn.rotation_degrees = -90
	
	velocity = velocity.normalized() * speed
	sprite.play("walk_" + direction)

var time = 0
func _physics_process(delta):
	time += delta
	if $"/root/Game/CanvasLayer/GameMenu".visible == false: # prevent moving while in the menu
		get_input()
		velocity = move_and_slide(velocity, Vector2(0, 0))
		velocitytext.text = "Velocity: " + str(velocity)
	
	if velocity == Vector2(0,0):
		sprite.stop()
		sprite.frame = 0
	
	if velocity != Vector2(0,0): # loop every 0.015 seconds
		Multiplayer.movement_update()
		time = 0
