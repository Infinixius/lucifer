extends Control

onready var bus = AudioServer.get_bus_index("Master")
onready var tween = $Tween
var todelete = false

func _ready():
	$ScrollContainer/Main/Noclip.pressed = Global.settings.noclip
	$ScrollContainer/Main/Lighting.pressed = Global.settings.lighting
	$ScrollContainer/Main/Discord.pressed = Global.settings.discord
	$ScrollContainer/Main/DevOptions.pressed = Global.settings.devOptions
	$ScrollContainer/Main/Silent.pressed = Global.settings.silent
	$ScrollContainer/Main/Fullscreen.pressed = Global.settings.fullscreen
	$ScrollContainer/Main/Volume.value = db2linear(AudioServer.get_bus_volume_db(bus))
	$ScrollContainer/Main/TickRate.value = Global.settings.tickRate
	
	tween.interpolate_property(self, "rect_position",
		Vector2(0, 1080), Vector2(0, 0), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	
func _on_Exit_pressed():
	Global.saveSettings()
	
	todelete = true
	tween.interpolate_property(self, "rect_position",
		Vector2(0, 0), Vector2(0, 1080), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _on_Noclip_toggled(button_pressed):
	Global.settings.noclip = button_pressed

func _on_Lighting_toggled(button_pressed):
	Global.settings.lighting = button_pressed

func _on_Discord_toggled(button_pressed):
	Global.settings.discord = button_pressed
	Global.updateDiscordRPC()

func _on_DevOptions_toggled(button_pressed):
	Global.settings.devOptions = button_pressed

func _on_Volume_value_changed(value):
	AudioServer.set_bus_volume_db(bus, linear2db(value))

func _on_Silent_toggled(button_pressed):
	Global.settings.silent = button_pressed

func _on_TickRate_value_changed(value):
	Global.settings.tickRate = value

func _on_Fullscreen_toggled(button_pressed):
	Global.settings.fullscreen = button_pressed


func _on_Tween_tween_completed(object, key):
	if todelete:
		queue_free()
