extends CanvasLayer

var Bullet = load("res://scenes/entities/Bullet.tscn")
var Enemy = load("res://scenes/entities/Enemy.tscn")

onready var bulletspawn = $"../Player/BulletSpawn"
onready var spark = $"../Player/BulletSpawn/Spark"

var shootCooldown = false

func _input(event):
	if event.is_action_pressed("GameMenu"):
		get_node("GameMenu").show()
	if Input.is_action_pressed("debug"):
		$"../CanvasLayer/Debug".visible = !$"../CanvasLayer/Debug".visible

#Options menu opens
func _on_Options_pressed():
	var options_menu = load("res://scenes/game/OptionsMenu.tscn").instance()
	add_child(options_menu)
	get_node("OptionsMenu").connect("CloseOptionsMenu", self,("CloseOptionsMenu"))

func CloseOptionsMenu():
	get_node("OptionsMenu").queue_free()

func _on_Exit_to_menu_pressed():
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")

func _process(_delta):
	$Debug.visible = Global.settings.devOptions
