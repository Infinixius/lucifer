extends Node

var Bullet = load("res://scenes/entities/Bullet.tscn")
var Enemy = load("res://scenes/entities/Enemy.tscn")

enum Entities {Unknown, Player, Bullet, Enemy}

func update():
	for i in self.get_children():
		pass

func spawnEntity(type, id, pos, _size, rot, _velocity, data):
	var entity = $".".get_node_or_null(str(id))
	if !entity:
		if type == Entities.Bullet:
			$"../Sounds".play("Shoot")
			var bullet = Bullet.instance()
			bullet.set_name(str(id))
			bullet.position.x = pos[0]
			bullet.position.y = pos[1]
			bullet.rotation_degrees = rot
			$".".add_child(bullet)
		elif type == Entities.Enemy:
			var enemy = Enemy.instance()
			enemy.set_name(str(id))
			#enemy.get_node("Enemy").position = enemy.get_global_position()
			enemy.get_node("Enemy").position.x = pos[0]
			enemy.get_node("Enemy").position.y = pos[1]
			enemy.get_node("Enemy").rotation_degrees = rot
			$".".add_child(enemy)
	else:
		updateEntity(id, pos, data)

func deleteEntity(id):
	var entity = $".".get_node_or_null(str(id))
	if entity:
		entity.queue_free() # delete the node

func updateEntity(id, pos, data):
	var entity = $".".get_node(str(id))
	if entity.get_node_or_null("Enemy"):
		entity.get_node("Enemy").set("asleep", data.asleep)
		if data.get("owner"):
			entity.get_node("Enemy").set("ownerID", data.owner)
			if data.owner != Global.id: # dont update enemy positions we already know, to prevent rubberbanding
				var newPos = Vector2(pos[0], pos[1])
				entity.get_node("Enemy").movingTo = newPos
				
	else:
		entity.position = entity.get_global_position()
		entity.position.x = pos[0]
		entity.position.y = pos[1]
