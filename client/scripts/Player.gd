extends KinematicBody2D

export (int) var speed = 350

onready var sprite = $AnimatedSprite
onready var tile_map = $"../Navigation2D/TileMap"
onready var player = self
onready var Multiplayer = $"../Players"
onready var velocitytext = $"../CanvasLayer/Debug/velocity_text"
onready var bulletspawn = $BulletSpawn
onready var camera = $AnimatedSprite/Camera2D
var DeathScreen = load("res://scenes/game/DeathScreen.tscn")

var velocity = Vector2()
var speedvel = 1000
var direction = 0
var direction_walk = "right"
var last_direction = "right"
var tracerOverlap = false

func get_input():
	if Global.isdead:
		return
	
	velocity = Vector2()
	
	if Input.is_action_pressed("right"):
		velocity.x += 1
		check_direction_walk()
		
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		check_direction_walk()
		
	if Input.is_action_pressed("down"):
		velocity.y += 1
		check_direction_walk()
		
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		check_direction_walk()
		
	if Input.is_action_pressed("shoot") and not Global.isdead:
		if $"/root/Game/CanvasLayer/GameMenu".visible == false:
			if not tracerOverlap:
				Multiplayer.shoot(direction)
			
		check_direction_walk()
	if Input.is_action_just_released("zoom_in") and not Global.isdead:
		if camera.zoom > Vector2(0.1, 0.1):
			camera.zoom = camera.zoom - Vector2(0.1, 0.1)
	if Input.is_action_just_released("zoom_out") and not Global.isdead:
		if camera.zoom < Vector2(1, 1):
			camera.zoom = camera.zoom + Vector2(0.1, 0.1)
	
	if not Global.isdead:
		velocity = velocity.normalized() * speed
		sprite.play("walk_" + direction_walk)
		if velocity != Vector2(0,0) and sprite.frame == 0:
			sprite.frame = 1
		
		if last_direction != direction_walk:
			last_direction = direction_walk
			Multiplayer.movement_update()

var time = 0
func _physics_process(delta):
	time += delta
	if $"/root/Game/CanvasLayer/GameMenu".visible == false and Global.isplaying and not Global.isdead: # prevent moving while in the menu
		get_input()
		velocity = move_and_slide(velocity, Vector2(0, 0))
		velocitytext.text = "Velocity: " + str(velocity)
	
	$Tracer.rotation_degrees = rad2deg(direction) - 90
	
	if Global.settings.noclip and Global.cheats:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
	
	if Global.settings.lighting_lighting == true:
		$AnimatedSprite/Light2D.enabled = true
		$Particles2D.visible = true
		$Particles2D2.visible = true
		$"../CanvasModulate".color = Color8(74, 33, 33)
	else:
		$AnimatedSprite/Light2D.enabled = false
		$Particles2D.visible = false
		$Particles2D2.visible = false
		$"../CanvasModulate".color = Color8(255, 255, 255)
	
	if Global.settings.lighting_shaders == true:
		$"../CanvasLayer/Vignette".visible = true
		$"../CanvasLayer/Distort".visible = true
	else:
		$"../CanvasLayer/Vignette".visible = false
		$"../CanvasLayer/Distort".visible = false
	
	if Global.isplaying and not Global.isdead:
		if velocity == Vector2(0,0):
			sprite.stop()
			sprite.frame = 0
		else:
			$"../Sounds".play("Walk")
		#elif sprite.frame == 0:
		#	sprite.frame = 1 # fixes a bug where the animation wouldnt play for a splitsecond after moving
		
		if velocity != Vector2(0,0): # loop every 0.015 seconds
			Multiplayer.movement_update()
			time = 0
		direction = get_angle_to(get_global_mouse_position() - Vector2(16,16))
	check_direction_walk()

func check_direction_walk():
	if rad2deg(direction) >= -45 and rad2deg(direction) <= 45:
		direction_walk = "right"
		
		bulletspawn.position.x = 32
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 0
	elif rad2deg(direction) >= 45 and rad2deg(direction) <= 135:
		direction_walk = "down"
		
		bulletspawn.position.x = 16
		bulletspawn.position.y = 32
		bulletspawn.rotation_degrees = 90
	elif rad2deg(direction) >= 135 or rad2deg(direction) <= -135:
		direction_walk = "left"
		
		bulletspawn.position.x = 0
		bulletspawn.position.y = 16
		bulletspawn.rotation_degrees = 180
	elif rad2deg(direction) >= -135 and rad2deg(direction) <= -45:
		direction_walk = "up"
		
		bulletspawn.position.x = 16
		bulletspawn.position.y = 0	
		bulletspawn.rotation_degrees = -90

func died():
	var deathscreen = DeathScreen.instance()
	$"/root/Game/CanvasLayer".add_child(deathscreen)

func _on_Tracer_body_entered(body):
	if body == $"/root/Game/Navigation2D/TileMap":
		tracerOverlap = true

func _on_Tracer_body_exited(body):
	if body == $"/root/Game/Navigation2D/TileMap":
		tracerOverlap = false

func _on_AnimatedSprite_frame_changed():
	if not Global.isdead:
		Multiplayer.movement_update()
