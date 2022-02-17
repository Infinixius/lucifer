extends Control

onready var bus = AudioServer.get_bus_index("Master")

func _ready():
	$Main/Noclip.pressed = Global.settings.noclip
	$Main/Lighting.pressed = Global.settings.lighting
	$Main/Discord.pressed = Global.settings.discord
	$Main/DevOptions.pressed = Global.settings.devOptions
	$Main/Volume.value = db2linear(AudioServer.get_bus_volume_db(bus))
	
func _on_Exit_pressed():
	queue_free()

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
	print(linear2db(value))
	AudioServer.set_bus_volume_db(bus, linear2db(value))
