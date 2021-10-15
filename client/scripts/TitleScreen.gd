extends Node2D

func _ready():
	$CanvasLayer/Version.text = "v" + Global.VERSION
