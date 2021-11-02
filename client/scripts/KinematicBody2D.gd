extends KinematicBody2D

var Bullet = load("res://Bullet.tscn")
var Enemy = load("res://Enemy.tscn")

export (int) var speed = 200

onready var tile_map = $"../TileMap"
onready var player = self
onready var Multiplayer = $"../Players"
onready var velocitytext = $"../CanvasLayer/Debug/velocity_text"
onready var bulletspawn = $BulletSpawn
onready var enemyspawn = $"../EnemyDevSpawn"

var velocity = Vector2()
var speedvel = 1000

func get_input():
	player.position = player.get_global_position()
	
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 32
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 0
	if Input.is_action_pressed("left"):
		velocity.x -= speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 0
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 180
	if Input.is_action_pressed("down"):
		velocity.y += speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 16
		bulletspawn.position.y = 32
		bulletspawn.rotation_degrees = 90
	if Input.is_action_pressed("up"):
		velocity.y -= speedvel
		bulletspawn.position = bulletspawn.get_global_position()
		bulletspawn.position.x = 16
		bulletspawn.position.y = 0
		bulletspawn.rotation_degrees = -90
	if Input.is_action_pressed("debug"):
		$"../CanvasLayer/Debug".visible = !$"../CanvasLayer/Debug".visible
	
	velocity = velocity.normalized() * speed
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("SpawnEnemy"):
		SpawnEnemy()

func shoot():
	var b = Bullet.instance()
	owner.add_child(b)
	b.transform = bulletspawn.global_transform

func SpawnEnemy():
	var e = Enemy.instance()
	owner.add_child(e)
	e.transform = enemyspawn.transform

var time = 0
func _physics_process(delta):
	time += delta
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
