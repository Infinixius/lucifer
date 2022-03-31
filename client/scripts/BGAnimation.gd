extends TileMap

func _ready():
	for x in range(512):
		for y in range(512):
			set_cell(x, y, randi() % 12)
			set_cell(x * -1, y, randi() % 12)

func _process(_delta):
	position = position + Vector2(0.1, -0.1)
	if position > Vector2(512, -512):
		position = Vector2(0, 0)
