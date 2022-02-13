extends Node

var Bullet = load("res://scenes/entities/Bullet.tscn")
var Enemy = load("res://scenes/entities/Enemy.tscn")

enum Entities {Unknown, Player, Bullet, Enemy}

func update():
	for i in self.get_children():
		pass

func spawnEntity(type, id, pos, _size, rot, _velocity):
	var entity = $".".get_node_or_null(str(id))
	if !entity:
		if type == Entities.Bullet:
			var bullet = Bullet.instance()
			bullet.set_name(str(id))
			bullet.position = bullet.get_global_position()
			bullet.position.x = pos[0]
			bullet.position.y = pos[1]
			bullet.rotation_degrees = rot
			$".".add_child(bullet)
		elif type == Entities.Enemy:
			var enemy = Enemy.instance()
			enemy.set_name(str(id))
			enemy.position = enemy.get_global_position()
			enemy.position.x = pos[0]
			enemy.position.y = pos[1]
			enemy.rotation_degrees = rot
			$".".add_child(enemy)
	else:
		updateEntity(id, pos)

func deleteEntity(id):
	var entity = $".".get_node_or_null(str(id))
	if entity:
		entity.queue_free() # delete the node

func updateEntity(id, pos):
	var entity = $".".get_node(str(id))
	if entity:
		entity.position = entity.get_global_position()
		entity.position.x = pos[0]
		entity.position.y = pos[1]
