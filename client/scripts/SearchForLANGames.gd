extends ConfirmationDialog

var LANGame = load("res://scenes/game/LANGame.tscn")

func _ready():
	popup()

func _on_StartLANGame_confirmed():
	dialog_text = "Searching.. This might take a second!\n\nMacOS and Linux support is experimental."
	for child in $Servers/VBoxContainer.get_children():
		child.queue_free()
	
	var servers = Global.SearchForLANGames()
	
	dialog_text = "These were all the LAN games found on your network. Click OK to search again.\n\nMacOS and Linux support is experimental."
	
	for server in servers:
		var servername = server.trim_suffix("\r").trim_suffix("\n")

		if servername == "NoServersFound":
			dialog_text = "There were no LAN games found on your network. Click OK to search again.\n\nMacOS and Linux support is experimental."
		else:
			var langame = LANGame.instance()
			langame.get_node("Label").text = servername
			$Servers/VBoxContainer.add_child(langame)

func _on_StartLANGame_about_to_show():
	$Tween.interpolate_property(self, "rect_position",
		Vector2(765, 1311), Vector2(765, 311), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()

func _on_StartLANGame_popup_hide():
	$Tween.interpolate_property(self, "rect_position",
		Vector2(765, 311), Vector2(765, 1311), 0.5,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
	queue_free()
