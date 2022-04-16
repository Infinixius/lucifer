extends KinematicBody2D

export (bool) var asleep = true
export (int) var speed = 10000
export (int) var ownerID = 0
export (bool) var smart = true
export (Vector2) var movingTo = Vector2(0,0)
export (Color) var enemyColor = Color(1,1,1)

onready var player = $"../../../Player"
onready var nav = $"/root/Game/Navigation2D"
onready var line = $AILine

var path = []
var pathpoint = 1

func _ready():
	add_collision_exception_with(player)

func update():
	$"../../../Players".send("enemy_ai", {
			"x": self.position.x,
			"y": self.position.y,
			"id": get_parent().name
		})

func canSee(pos1, pos2):
	var space_state = get_world_2d().direct_space_state
	if pos1.distance_to(pos2) < 512:
		var result = space_state.intersect_ray(pos1, pos2, [player, self], 2)
		return result.size() == 0

func move(delta):
	var enemy_angle = get_angle_to($"/root/Game/Player".position + Vector2(16, 16))
	
	if smart:
		if Global.settings.devOptions:
			if not canSee(player.global_position, self.global_position):
				line.default_color = Color(0,1,0,1)
				for pathpointx in path:
					line.add_point(line.to_local(pathpointx))
			else:
				line.default_color = Color(0,0,1,1)
				line.add_point(line.to_local($"/root/Game/Player".position + Vector2(16, 16)))
				line.add_point(line.to_local(global_position))
		
		if range(path.size()).has(pathpoint):
			if global_position.distance_to(path[pathpoint]) < 1:
				pathpoint += 1
		
		if range(path.size()).has(pathpoint) and not canSee(player.global_position, self.global_position):
			enemy_angle = get_angle_to(path[pathpoint])
		
	var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
	
	# warning-ignore:return_value_discarded
	move_and_slide(vector_angle * speed * delta)

var time = 0
func _process(delta):
	time = time + delta
	if get_node("Sprite").modulate.g < 1:
		get_node("Sprite").modulate.g += 0.05
		get_node("Sprite").modulate.b += 0.05
	
	if time > Global.settings.tickRate and ownerID == Global.id:
		update()
		time = 0
	
	if Global.settings.lighting_effects == true:
		$Light2D.visible = true
	else:
		$Light2D.visible = false

var seetime = 0
var pathtime = 0
func _physics_process(delta):
	line.clear_points()
	seetime += delta
	pathtime += delta
	
	if asleep == true and seetime > 0.5 and not Global.isdead:
		if Global.settings.silent and Global.cheats:
			return
		seetime = 0
		if canSee(player.global_position, self.global_position):
			$"/root/Game/Players".send("enemy_seen", get_parent().name)
	
	elif asleep == false and ownerID == Global.id:
		if pathtime > 0.25:
			pathtime = 0
			path = []
			if not canSee(player.global_position, self.global_position):
				path = nav.get_simple_path(nav.to_local(position), nav.to_local($"/root/Game/Player".position) + Vector2(16, 16), true)
				pathpoint = 1
			
		move(delta)
		
		if global_position.distance_to($"../../../Player".global_position + Vector2(16, 16)) < 16:
			$"../../../Players".enemyAttack("melee", get_parent().name)
	elif asleep == false and not ownerID == Global.id:
		var enemy_angle = get_angle_to(movingTo)
		var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
		
		# warning-ignore:return_value_discarded
		move_and_slide(vector_angle * speed * delta)
