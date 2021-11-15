extends TextureProgress

func _on_KinematicBody2D_PlayerHealthChanged(NewValue):
	self.value = NewValue
	health_text.text = str("Health: ") + str(NewValue)
