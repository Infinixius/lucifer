extends AudioStreamPlayer

var stone_sound = preload("res://assets/sfx/step_stone.mp3")

func playFootstep(type):
	if !self.is_playing():
		if type == "stone":
			self.stream = stone_sound
			self.play()
