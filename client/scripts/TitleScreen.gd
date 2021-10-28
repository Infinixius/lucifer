		extends Node2D

func _ready():
	$CanvasLayer/Version.text = "v" + Global.VERSION
	if Global.error != "":
		$CanvasLayer/Error.text = Global.error
		Global.error = ""
