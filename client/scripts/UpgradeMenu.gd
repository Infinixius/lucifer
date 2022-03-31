extends Control

onready var tween = $Tween
var todelete = false

func _ready():
	if Global.ingame:
		Global.isplaying = false
	tween.interpolate_property(self, "rect_position",
		Vector2(0, 1080), Vector2(0, 0), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _input(event):
	if event.is_action_pressed("GameMenu"):
		todelete = true
		tween.interpolate_property(self, "rect_position",
			Vector2(0, 0), Vector2(0, 1080), 0.5,
			Tween.TRANS_QUART, Tween.EASE_OUT)
		tween.start()

func _on_Exit_pressed():
	todelete = true
	tween.interpolate_property(self, "rect_position",
		Vector2(0, 0), Vector2(0, 1080), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if todelete:
		if Global.ingame:
			Global.isplaying = true
		queue_free()

func _on_Downgrade(type):
	$"/root/Players".shop("downgrade", type)

func _on_Upgrade(type):
	$"/root/Game/Players".shop("upgrade", type)
