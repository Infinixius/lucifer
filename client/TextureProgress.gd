extends TextureProgress

func _ready():
	pass



func _on_KinematicBody2D_PlayerHealthChanged(NewValue):
	TextureProgress.value = int(NewValue)
