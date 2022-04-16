const { Player } = require("../classes/Player.js")
const { Client } = require("../classes/Client.js")
const npmpackage = require("../package.json")

module.exports.onJoin = function(ws, req) { // fired when a player joins
	playerID++
	ws.client = new Client(ws, req, playerID)
	ws.player = new Player(ws.client, ws.client.options.get("username"))

	Logger.log(`Client connected! ID: "${playerID}" IP: "${ws.client.ip}"`)

	if (ws.client.options.get("version") != npmpackage.version) {
		return ws.client.kick(`Mismatched version. This server is on ${npmpackage.version}.`)
	}
	clients.push(ws.client)

	let playerArray = []
	for (const client of clients) {
		playerArray.push({
			"id": client.id,
			"name": client.fetchPlayer().name,
			"position": client.fetchPlayer().position
		})
	}

	broadcast("system_message", ws.player.name + " connected")
	ws.client.send("player_initalize", {
		"id": ws.client.id,
		"players": playerArray
	})
	enemies.networkUpdate(true)
	broadcast("player_connect", {
		"id": ws.client.id,
		"name": ws.player.name
	})
	map.send(ws)
	ws.player.networkUpdate(true)

	// events
	ws.on("message", (msg) => { onMessage(ws, msg) }) // on message event
	ws.on("close", () => { onClose(ws, ws) })

	// ping
	setInterval(function() {
		ws.client.send("ping", { timestamp: Date.now() })
	}, config.pingInterval)
}

function onMessage(ws, message) { /* fired when we get a message */
	Logger.debug(`Raw message received from client #${ws.client.id}: "${message.toString()}"`)
	try { var data = JSON.parse(message.toString()) } catch (err) {
		return Logger.error(`Failed to parse data received from client #${ws.client.id}! Data: "${message.toString()}" Error: ${err}`)
	}

	ws.client.lastMessage = Date.now()

	switch (data.type) {	 
		case "player_move":
			ws.player.moveTo(data.message.x, data.message.y)
			ws.player.animation = {
				name: data.message.animation,
				frame: data.message.animationframe
			}

			ws.player.networkUpdate()
			break
		case "send_message":
			Logger.log(`${ws.player.name} (${ws.client.id}) said: ${data.message.slice(0,256)}`)
			broadcast("receive_message", {
				"name": ws.player.name,
				"message": data.message.slice(0,256)
			})
			break
		case "player_shoot":
			ws.player.bullets.createBullet(
				ws.player.position,
				data.message.direction
			)
			ws.player.bullets.networkUpdate()
			break
		case "bullet_hit":
			if (data.message.type == "wall") {
				ws.player.bullets.hit(data.message.id, data.message.collision)
			} else if (data.message.type == "enemy") {
				var enemy = enemies.enemies.get(data.message.id)
				if (enemy) {
					if (!ws.player.upgrades.abilities.piercing) {
						ws.player.bullets.hit(data.message.bullet)
					}

					var damage = lime.random(5, 10)
					damage +=  damage * (ws.player.upgrades.skills.strength / 2)
					if (ws.player.upgrades.abilities.rejuvenation) {
						ws.player.heal(Math.round(damage / 10))
					}
					enemy.hurt(damage, ws.player.client.id)
				}
			}
			break
		case "enemy_seen":
			var enemy = enemies.enemies.get(Number(data.message))
			if (enemy) {
				if (enemy.asleep == true) {
					enemy.awaken(ws.client.id)
				}
			}
			break
		case "enemy_sleep":
			var enemy = enemies.enemies.get(Number(data.message))
			if (enemy) {
				enemy.goToSleep()
			}
			break
		case "enemy_ai":
			var enemy = enemies.enemies.get(Number(data.message.id))
			if (enemy) {
				enemy.moveTo(data.message.x, data.message.y)
			}
			break
		case "player_shop":
			if (data.message.type == "upgrade") {
				ws.player.upgrade(data.message.item)
			} else if (data.message.type == "upgrade_ability") {
				ws.player.upgradeAbility(data.message.item)
			}
			break
		case "enemy_attack":
			var enemy = enemies.enemies.get(Number(data.message.id))
			if (enemy) {
				enemy.attack(ws.player, data.message.type)
			}
			break
		case "konami":
			if (ws.player.konami) return
			Logger.log(`${ws.player.name} (${ws.client.id}) activated the Konami Code!`)
			ws.player.konami = true
			ws.player.maxhealth = 1000
			ws.player.health = ws.player.maxhealth
			ws.player.coins = 9999999999
			ws.player.upgrades = {
				skills: {
					health: 10,
					speed: 10,
					strength: 10,
					luck: 10,
					reload: 10,
					bulletspeed: 10
				},
				abilities: {
					"piercing": true,
					"regeneration": true,
					"rejuvenation": true,
				}
			}
			break
		case "player_exit":
			ws.player.leaving = data.message
			break
		case "respawn":
			const player = new Player(ws.client, ws.player.name)
			ws.client.player = player
			ws.player = player
			player.networkUpdate(true)
			player.client.send("player_respawn", { id: player.client.id })
			break
		case "chest_open":
			var chest = map.chests.find(chest => chest.id == data.message)
			if (chest) {
				chest.open(ws.player)
			}
			break
	}
}
module.exports.onMessage = onMessage

function onClose(ws) {
	broadcast("system_message", `${ws.player.name} disconnected!`)
	Logger.log(`Client #${ws.client.id} disconnected!`)
	
	broadcast("player_disconnect", ws.client.id)

	var player = clients.find(plr => { return plr.id == ws.client.id })
		player.kick("Disconnected")
		clients.splice(clients.indexOf(player), 1)
	
	ws.terminate()
}
module.exports.onClose = onClose