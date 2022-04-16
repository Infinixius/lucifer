extends Node

var Bullet = load("res://scenes/entities/Bullet.tscn")
var Enemy = load("res://scenes/entities/Enemy.tscn")
var EnemyEyeball = load("res://scenes/entities/EnemyEyeball.tscn")
var Chest = load("res://scenes/entities/Chest.tscn")

var EnemyDeath = load("res://scenes/entities/EnemyDeath.tscn")

enum Entities {Unknown, Player, Bullet, Enemy, EnemyEyeball, Chest}

func update():
	for i in self.get_children():
		pass

func spawnEntity(type, id, pos, _size, rot, velocity, data):
	var entity = $".".get_node_or_null(str(id))
	if !entity:
		if type == Entities.Bullet:
			$"../Sounds".play("Shoot")
			var bullet = Bullet.instance()
			$".".add_child(bullet)
			bullet.set_name(str(id))
			bullet.position.x = pos[0]
			bullet.position.y = pos[1]
			bullet.rotation_degrees = rot
			bullet.get_node("Bullet").speed = velocity
		elif type == Entities.Enemy:
			var enemy = Enemy.instance()
			$".".add_child(enemy)
			enemy.set_name(str(id))
			enemy.get_node("Enemy").position = Vector2(pos[0], pos[1])
			enemy.get_node("Enemy").rotation_degrees = rot
		elif type == Entities.EnemyEyeball:
			var enemy = EnemyEyeball.instance()
			$".".add_child(enemy)
			enemy.set_name(str(id))
			enemy.get_node("Enemy").position = Vector2(pos[0], pos[1])
			enemy.get_node("Enemy").rotation_degrees = rot
			enemy.get_node("Enemy").get_node("Sprite").frames = load("res://assets/entities/enemy_eyeball/EnemyEyeball_lv" + str(data.level) + ".tres")
		elif type == Entities.Chest:
			var chest = Chest.instance()
			$"/root/Game/Navigation2D/TileMap".add_child(chest)
			chest.set_name(str(id))
			chest.get_node("Chest").chestID = data.id
			chest.get_node("Chest").gold = data.gold
			if data.opened:
				chest.get_node("Chest").open(data.loot)
			chest.get_node("Chest").global_position = Vector2(pos[0], pos[1])
	else:
		updateEntity(id, pos, data)

func deleteEntity(id):
	var entity = $".".get_node_or_null(str(id))
	if entity:
		if entity.get_node_or_null("Enemy"):
			var enemy = entity.get_node_or_null("Enemy")
			$"/root/Game/Sounds".play("EnemyKill")
			
			if Global.settings.lighting_particles == true:
				var enemydeath = EnemyDeath.instance()
				enemydeath.global_position = enemy.global_position
				enemydeath.process_material.color = enemy.enemyColor
				$"/root/Game/".add_child(enemydeath)

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
	elif entity.get_node_or_null("Chest"):
		if data.opened:
			entity.get_node_or_null("Chest").open(data.loot)
	
	else:
		entity.position = entity.get_global_position()
		entity.position.x = pos[0]
		entity.position.y = pos[1]
		entity.rotation = data.rotation
