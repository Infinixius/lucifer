extends CanvasLayer


func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("GameMenu"):
		get_node("GameMenu").show()


#Options menu opens
func _on_Options_pressed():
	var options_menu = load("res://OptionsMenu.tscn").instance()
	add_child(options_menu)
	get_node("OptionsMenu").connect("CloseOptionsMenu", self,("CloseOptionsMenu"))

func CloseOptionsMenu():
	get_node("OptionsMenu").queue_free()


func _on_Exit_to_menu_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
