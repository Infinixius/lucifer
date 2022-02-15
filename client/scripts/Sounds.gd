extends Node

func play(sound):
	var player = get_node_or_null(sound)
	
	if player:
		if !player.is_playing():
			player.play()
