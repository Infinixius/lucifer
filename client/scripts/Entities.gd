extends Node

var Bullet = load("res://scenes/entities/Bullet.tscn")

enum Entities {Unknown, Player, Bullet, Enemy}

func update():
	for i in self.get_children():
		pass

func spawnEntity(type, id, pos, size, rot, velocity):
	if type == Entities.Bullet:
		var bullet = Bullet.instance()
		bullet.name = str(id)
		bullet.position = bullet.get_global_position()
		bullet.position.x = pos[0] + 16 # offset by 16
		bullet.position.y = pos[1] + 16 # offset by 16
		bullet.rotation_degrees = rot
		$".".add_child(bullet)

func deleteEntity(id):
	var entity = get_node(str(id))
	entity.queue_free() # delete the node
