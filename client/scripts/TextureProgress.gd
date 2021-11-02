extends TextureProgress

onready var health_text = $"/root/Game/CanvasLayer/Debug/health_text"

func _ready():
	pass


func _on_KinematicBody2D_PlayerHealthChanged(NewValue):
	self.value = NewValue
	health_text.text = str("Health: ") + str(NewValue)
	
