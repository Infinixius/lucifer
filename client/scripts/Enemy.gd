extends KinematicBody2D

export (bool) var asleep = true
export (int) var speed = 10000
export (int) var ownerID = 0
export (bool) var smart = true
export (Vector2) var swarmingTo = Vector2(0,0)
export (Vector2) var movingTo = Vector2(0,0)
export (Color) var enemyColor = Color(1,1,1)

onready var player = $"../../../Player"
onready var nav = $"/root/Game/Navigation2D"

func _ready():
	add_collision_exception_with(player)

func update():
	$"../../../Players".send("enemy_ai", {
			"x": self.position.x,
			"y": self.position.y,
			"id": get_parent().name
		})

func move(delta):
	if smart:
		"""
		if swarmingTo == Vector2(0,0):
			var swarmers = $Swarm.get_overlapping_bodies()
			for swarmer in swarmers:
				if swarmer.name == "Enemy":
					if swarmer.swarmingTo != Vector2(0,0):
						swarmingTo = swarmer.swarmingTo
						break
		
		if swarmingTo == Vector2(0,0):
			#var path = nav.get_simple_path(nav.to_local(position), nav.to_local($"/root/Game/Player".position))
			
			#if path.size() > 1:
			swarmingTo = $"/root/Game/Player".position #path[1]
		"""
		var enemy_angle = get_angle_to($"/root/Game/Player".position)
		var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
		
		# warning-ignore:return_value_discarded
		move_and_slide(vector_angle * speed * delta)
	else:
		var enemy_angle = get_angle_to($"/root/Game/Player".position)
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
var swarmtime = 0
func _physics_process(delta):
	seetime += delta
	swarmtime += delta

	if swarmtime > 0.5:
		swarmtime = 0
		swarmingTo = Vector2(0,0)
	
	if asleep == true and seetime > 0.5 and not Global.isdead:
		if Global.settings.silent and Global.cheats:
			return
		seetime = 0
		var space_state = get_world_2d().direct_space_state
		var enemyPos = Vector2(position.x + 16, position.y + 16)
		if enemyPos.distance_to(player.position) < 512:
			var result = space_state.intersect_ray(player.position, enemyPos, [player, self])
			if result.size() == 0:
				$"/root/Game/Players".send("enemy_seen", get_parent().name)
	
	elif asleep == false and ownerID == Global.id:
		move(delta)
		
		if position.distance_to($"../../../Player".position) < 16:
			$"../../../Players".enemyAttack("melee", get_parent().name)
	elif asleep == false and not ownerID == Global.id:
		var enemy_angle = get_angle_to(movingTo)
		var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
		
		# warning-ignore:return_value_discarded
		move_and_slide(vector_angle * speed * delta)
