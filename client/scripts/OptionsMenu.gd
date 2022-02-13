extends Control

func _ready():
	print("ok")
	$Main/Noclip.pressed = Global.settings.noclip
	$Main/Lighting.pressed = Global.settings.lighting
	
func _on_Exit_pressed():
	queue_free()

func _on_Noclip_toggled(button_pressed):
	Global.settings.noclip = button_pressed


func _on_Lighting_toggled(button_pressed):
	Global.settings.lighting = button_pressed
