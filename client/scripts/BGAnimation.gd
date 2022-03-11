extends TileMap

func _ready():
	for x in range(1024):
		for y in range(1024):
			set_cell(x, y, randi() % 12)
			set_cell(x * -1, y, randi() % 12)

func _process(_delta):
	position = position + Vector2(0.1, -0.1)
	if position > Vector2(1024, -1024):
		position = Vector2(0, 0)
