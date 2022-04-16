extends Area2D

export (int) var chestID = 0
export (bool) var opened = false
export (bool) var gold = false

onready var tween = $Loot/Tween

func _process(_delta):
	if gold:
		if opened:
			$Sprite.texture = load("res://assets/entities/chest/chestopen_gold.png")
		else:
			$Sprite.texture = load("res://assets/entities/chest/chestclosed_gold.png")
	else:
		if opened:
			$Sprite.texture = load("res://assets/entities/chest/chestopen.png")
		else:
			$Sprite.texture = load("res://assets/entities/chest/chestclosed.png")

func open(loot):
	if opened:
		return
	
	$Loot.append_bbcode("[center]\n")
	for lootmessage in loot:
		if "coin" in lootmessage:
			$Loot.append_bbcode("[color=yellow]" + lootmessage + "[/color]\n")
		elif "health" in lootmessage:
			$Loot.append_bbcode("[color=red]" + lootmessage + "[/color]\n")
		else:
			$Loot.append_bbcode(lootmessage + "\n")
	
	opened = true
	$BulletPuff.emitting = true
	$"/root/Game/Sounds".play("Chest")
	
	tween.interpolate_property($Loot, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 0.75,
		Tween.TRANS_QUART, Tween.EASE_IN)
	
	tween.interpolate_property($Loot, "rect_position",
		Vector2(-68, -130), Vector2(-68, -180), 0.75,
		Tween.TRANS_QUART, Tween.EASE_IN)
	
	tween.start()

func _on_Chest_body_entered(body):
	if body == $"/root/Game/Player" and not opened:
		$"/root/Game/Players".send("chest_open", chestID)
