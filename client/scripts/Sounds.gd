extends Node

func play(sound):
	var player = get_node_or_null(sound)
	
	if player:
		if not sound == "Walk":
			player.play()
		else:
			if !player.is_playing():
				player.play()
