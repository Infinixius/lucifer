extends KinematicBody2D

export (bool) var asleep = true
export (int) var speed = 10000
export (int) var ownerID = 0

func _ready():
	add_collision_exception_with($"../../../Player")

func update():
	$"../../../Players".send("enemy_ai", {
			"x": self.position.x,
			"y": self.position.y,
			"id": get_parent().name
		})

var time = 0
func _process(delta):
	time = time + delta
	if asleep:
		get_node("Sprite").modulate = Color(0,0,1)
	else:
		get_node("Sprite").modulate = Color(0,1,0)
	
	if time > Global.settings.tickRate and ownerID == Global.id:
		update()
		time = 0

func _physics_process(delta):
	if asleep == false and ownerID == Global.id:
		var enemy_angle = get_angle_to($"../../../Player".position)
		var vector_angle = Vector2(round(cos(enemy_angle)), round(sin(enemy_angle)))
		
		move_and_slide(vector_angle * speed * delta)