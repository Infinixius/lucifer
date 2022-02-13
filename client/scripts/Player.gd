extends KinematicBody2D

export (int) var speed = 350

onready var sprite = $AnimatedSprite
onready var tile_map = $"../TileMap"
onready var player = self
onready var Multiplayer = $"../Players"
onready var velocitytext = $"../CanvasLayer/Debug/velocity_text"
onready var bulletspawn = $BulletSpawn
onready var camera = $AnimatedSprite/Camera2D

var velocity = Vector2()
var speedvel = 1000
var direction = 0
var direction_walk = "right"

func get_input():
	velocity = Vector2()
	
	if Input.is_action_pressed("right"):
		velocity.x += speedvel
		check_direction_walk()
		
	if Input.is_action_pressed("left"):
		velocity.x -= speedvel
		check_direction_walk()
		
	if Input.is_action_pressed("down"):
		velocity.y += speedvel
		check_direction_walk()
		
	if Input.is_action_pressed("up"):
		velocity.y -= speedvel
		check_direction_walk()
		
	if Input.is_action_pressed("shoot"):
		if $"/root/Game/CanvasLayer/GameMenu".visible == false:
			Multiplayer.shoot(direction)
		check_direction_walk()
	if Input.is_action_just_released("zoom_in"):
		if camera.zoom > Vector2(0.15, 0.15):
			camera.zoom = camera.zoom - Vector2(0.15, 0.15)
	if Input.is_action_just_released("zoom_out"):
		if camera.zoom < Vector2(1, 1):
			camera.zoom = camera.zoom + Vector2(0.15, 0.15)
	
	velocity = velocity.normalized() * speed
	sprite.play("walk_" + direction_walk)
	if velocity != Vector2(0,0) and sprite.frame == 0:
		sprite.frame = 1
		

var time = 0
func _physics_process(delta):
	time += delta
	if $"/root/Game/CanvasLayer/GameMenu".visible == false: # prevent moving while in the menu
		get_input()
		velocity = move_and_slide(velocity, Vector2(0, 0))
		velocitytext.text = "Velocity: " + str(velocity)
	
	$CollisionShape2D.disabled = Global.settings.noclip
	if Global.settings.lighting == true:
		$AnimatedSprite/Light2D.enabled = true
		$"../CanvasModulate".color = Color8(81, 81, 81)
		$"../CanvasLayer/Vignette".visible = true
	else:
		$AnimatedSprite/Light2D.enabled = false
		$"../CanvasModulate".color = Color8(255, 255, 255)
		$"../CanvasLayer/Vignette".visible = false
	
	var space_state = get_world_2d().direct_space_state
	for entity in $"../Entities".get_children():
		if entity.get_node_or_null("Enemy"):
			var result = space_state.intersect_ray(self.position, entity.position, [self])
			if result.size() == 0:
				$"../Players".send("enemy_seen", entity.name)
	
	if velocity == Vector2(0,0):
		sprite.stop()
		sprite.frame = 0
	#elif sprite.frame == 0:
	#	sprite.frame = 1 # fixes a bug where the animation wouldnt play for a splitsecond after moving
	
	if velocity != Vector2(0,0): # loop every 0.015 seconds
		Multiplayer.movement_update()
		time = 0
	direction = get_angle_to(get_global_mouse_position())
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
