extends KinematicBody2D

export (bool) var asleep = true
export (int) var speed = 10000
export (int) var ownerID = 0
export (Vector2) var movingTo = Vector2(0,0)
export (Color) var enemyColor = Color(1,1,1)
onready var player = $"../../../Player"

func _ready():
	add_collision_exception_with(player)

func update():
	$"../../../Players".send("enemy_ai", {
			"x": self.position.x,
			"y": self.position.y,
			"id": get_parent().name
		})

var time = 0
func _process(delta):
	time = time + delta
	if get_node("Sprite").modulate.g < 1:
		get_node("Sprite").modulate.g += 0.05
		get_node("Sprite").modulate.b += 0.05
	
	if time > Global.settings.tickRate and ownerID == Global.id:
		update()
		time = 0
	
	if Global.settings.lighting == true:
		$Light2D.visible = true
	else:
		$Light2D.visible = false

var seetime = 0
func _physics_process(delta):
	seetime += delta
	if asleep == true and not Global.settings.silent and seetime > 1 and not Global.isdead and Global.cheats:
		seetime = 0
		var space_state = get_world_2d().direct_space_state
		var enemyPos = Vector2(position.x + 16, position.y + 16)
		if enemyPos.distance_to(player.position) < 512:
			var result = space_state.intersect_ray(player.position, enemyPos, [player, self])
			if result.size() == 0:
				$"/root/Game/Players".send("enemy_seen", get_parent().name)
	
	elif asleep == false and ownerID == Global.id:
		var enemy_angle = get_angle_to($"../../../Player".position)
		var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
		
		move_and_slide(vector_angle * speed * delta)
		
		if position.distance_to($"../../../Player".position) < 16:
			$"../../../Players".enemyAttack("melee", get_parent().name)
	elif asleep == false and not ownerID == Global.id:
		var enemy_angle = get_angle_to(movingTo)
		var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
		
		move_and_slide(vector_angle * speed * delta)
