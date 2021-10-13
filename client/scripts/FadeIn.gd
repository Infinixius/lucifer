extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true

var transparency = 1.0
func _process(delta):
	if self.visible == true and transparency > 0.0:
		transparency -= 0.01
		self.color = Color(0,0,0, transparency)
