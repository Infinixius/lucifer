extends KinematicBody2D

export (int) var speed = 200

onready var _animated_sprite = $AnimatedSprite



onready var tile_map = $"../TileMap"
onready var player = self
onready var Multiplayer = $"../Players"
onready var velocitytext = $"../CanvasLayer/Debug/velocity_text"
onready var bulletspawn = $BulletSpawn

var velocity = Vector2()
var speedvel = 1000

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		_animated_sprite.play("walk_right")
		velocity.x += speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 32
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 0
	if Input.is_action_pressed("left"):
		_animated_sprite.play("walk_left")
		velocity.x -= speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 0
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 180
	if Input.is_action_pressed("down"):
		_animated_sprite.play("walk_down")
		velocity.y += speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 16
		bulletspawn.position.y = 32
		bulletspawn.rotation_degrees = 90
	if Input.is_action_pressed("up"):
		_animated_sprite.play("walk_up")
		velocity.y -= speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 16
		bulletspawn.position.y = 0
		bulletspawn.rotation_degrees = -90
	
	velocity = velocity.normalized() * speed


var time = 0
func _physics_process(delta):
	time += delta
	if $"/root/Game/CanvasLayer/GameMenu".visible == false: # prevent moving while in the menu
		get_input()
		velocity = move_and_slide(velocity, Vector2(0, 0))
		velocitytext.text = "Velocity: " + str(velocity)
	
	
	if velocity != Vector2(0,0): # loop every 0.015 seconds
		Multiplayer.movement_update()
		time = 0


#health stuff
var PlayerHealth = 100
signal PlayerHealthChanged

func _on_Area2D_area_entered(area):
	PlayerHealth -= 50
	if PlayerHealth < 1:
		PlayerHealth = 0
	emit_signal("PlayerHealthChanged" , PlayerHealth)
