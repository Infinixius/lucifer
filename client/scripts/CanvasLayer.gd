extends CanvasLayer

var Bullet = load("res://Bullet.tscn")
var Enemy = load("res://Enemy.tscn")

onready var bulletspawn = $"../Player/BulletSpawn"
onready var enemyspawn = $"../EnemyDevSpawn"
onready var spark = $"../Player/BulletSpawn/Spark"

var shootCooldown = false

func _input(event):
	if event.is_action_pressed("GameMenu"):
		get_node("GameMenu").show()
	if Input.is_action_pressed("debug"):
		$"../CanvasLayer/Debug".visible = !$"../CanvasLayer/Debug".visible
	if Input.is_action_just_pressed("shoot"):
		if shootCooldown == false && $"/root/Game/CanvasLayer/GameMenu".visible == false:
			shoot()
			shootCooldown = true
			yield(get_tree().create_timer(0.25), "timeout") # wait 0.25 seconds
			shootCooldown = false
	if Input.is_action_just_pressed("SpawnEnemy"):
		SpawnEnemy()

func shoot():
	var b = Bullet.instance()
	owner.add_child(b)
	b.transform = bulletspawn.global_transform
	
	spark.visible = true
	yield(get_tree().create_timer(0.25), "timeout") # wait 0.25 seconds
	spark.visible = false

func SpawnEnemy():
	var e = Enemy.instance()
	owner.add_child(e)
	e.transform = enemyspawn.transform

#Options menu opens
func _on_Options_pressed():
	var options_menu = load("res://OptionsMenu.tscn").instance()
	add_child(options_menu)
	get_node("OptionsMenu").connect("CloseOptionsMenu", self,("CloseOptionsMenu"))

func CloseOptionsMenu():
	get_node("OptionsMenu").queue_free()

func _on_Exit_to_menu_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
