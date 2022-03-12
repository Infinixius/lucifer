extends Control

onready var tween = $Tween
var todelete = false

func _ready():
	tween.interpolate_property(self, "rect_position",
		Vector2(153, 1071), Vector2(153, 71), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _on_TextureButton_pressed():
	todelete = true
	tween.interpolate_property(self, "rect_position",
		Vector2(153, 71), Vector2(153, 1071), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if todelete:
		queue_free()

# handle URL clicks
func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(str(meta))
