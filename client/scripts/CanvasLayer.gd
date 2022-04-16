extends CanvasLayer

var Bullet = load("res://scenes/entities/Bullet.tscn")
var Enemy = load("res://scenes/entities/Enemy.tscn")

onready var bulletspawn = $"../Player/BulletSpawn"
onready var spark = $"../Player/BulletSpawn/Spark"
onready var tween = $Chat/Tween

var shootCooldown = false

func _input(event):
	if event.is_action_pressed("GameMenu") and Global.isplaying:
		if $GameMenu.visible:
			$GameMenu.visible = false
		else:
			$GameMenu.visible = true
	if Input.is_action_pressed("debug"):
		$"../CanvasLayer/Debug".visible = !$"../CanvasLayer/Debug".visible

#Options menu opens
func _on_Options_pressed():
	var options_menu = load("res://scenes/game/OptionsMenu.tscn").instance()
	add_child(options_menu)
	# warning-ignore:return_value_discarded
	get_node("OptionsMenu").connect("CloseOptionsMenu", self, ("CloseOptionsMenu"))

func CloseOptionsMenu():
	get_node("OptionsMenu").queue_free()

func _on_Exit_to_menu_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game/TitleScreen.tscn")

func showChat():
	"""
	tween.stop($Chat)
	$Chat.modulate = Color(1,1,1,1)
	
	yield(get_tree().create_timer(5), "timeout")
	tween.interpolate_property($Chat, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 0.25,
		Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()
	"""

func _process(_delta):
	$Debug.visible = Global.settings.devOptions
	
	if $Vignette.modulate.r > 0:
		$Vignette.modulate.r -= 0.015
	if $Vignette.modulate.g > 0:
		$Vignette.modulate.g -= 0.015
	if $Vignette.modulate.b > 0:
		$Vignette.modulate.b -= 0.015
