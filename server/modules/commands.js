const readline = require("readline")

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
})

module.exports.consoleCommand = function() {
	rl.question("", message => {
		module.exports.command(message)
		module.exports.consoleCommand()
	})
}

module.exports.command = function(string) {
	const args = string.trim().split(/ +/)
	const commandName = args.shift().toLowerCase()

	switch (commandName) {
		case "ping":
			Logger.log("Pong!")
			break
		case "list":
			var names = ""
			global.clients.forEach(client => {
				names += `${client.fetchPlayer().name} (${client.id}), `
			})
			Logger.log(`List of players: (${global.clients.length} total): ${names.slice(0, -2)}`)
			break
		case "summon":
			if (!config.cheats) return Logger.log("Cheats must be enabled to use this command!")
			global.enemies.createEnemy([args[0] ?? 128, args[1] ?? 128])
			break
		case "stop":
			Logger.log("Stopping the server!")
			clients.forEach(client => {
				client.kick("Server is shutting down!")
			})
			process.exit()
			break
		case "teleport":
			var client = clients.find(client => client.id == Number(args[0]))
			if (client) {
				var player = client.fetchPlayer()
				player.moveTo(Number(args[1]) * 16, Number(args[2]) * 16)
				player.networkUpdate()
				Logger.log(`Teleported "${player.name}" (${client.id}) to ${args[1]}, ${args[2]}`)
			} else {
				Logger.log(`Couldn't find player ID #${args[0]}`)
			}
			break
		case "eval":
			var code = args.join(" ")
			var result
			
			try {
				result = eval(code)
			} catch(err) {
				result = err
			}

			if (!result) result = "No result"
			Logger.log(result)
			break
		case "config":
			var option = args[0]
			if (config[option]) {
				args.shift()

				var result = args.join(" ")
				config[option] = result

				Logger.log(`Set ${option} to ${result}`)
			} else {
				Logger.log("No such config option exists!")
			}
			break
		case "setcoins":
			if (!config.cheats) return Logger.log("Cheats must be enabled to use this command!")
			var client = clients.find(client => client.id == Number(args[0]))
			if (client) {
				var player = client.fetchPlayer()
				player.coins = Number(args[1])
				player.networkUpdate()
				Logger.log(`Set "${player.name}" (${client.id})'s coins to ${args[1]}`)
			} else {
				Logger.log(`Couldn't find player ID #${args[0]}`)
			}
			break
		case "heal":
			if (!config.cheats) return Logger.log("Cheats must be enabled to use this command!")
			var client = clients.find(client => client.id == Number(args[0]))
			if (client) {
				var player = client.fetchPlayer()
				player.heal(Number(args[1]))
				player.networkUpdate()
				Logger.log(`Set "${player.name}" (${client.id})'s health to ${player.health}`)
			} else {
				Logger.log(`Couldn't find player ID #${args[0]}`)
			}
			break
		case "hurt":
			if (!config.cheats) return Logger.log("Cheats must be enabled to use this command!")
			var client = clients.find(client => client.id == Number(args[0]))
			if (client) {
				var player = client.fetchPlayer()
				player.hurt(Number(args[1]), "Attacked from a command.")
				player.networkUpdate()
				Logger.log(`Set "${player.name}" (${client.id})'s health to ${player.health}`)
			} else {
				Logger.log(`Couldn't find player ID #${args[0]}`)
			}
			break
		default:
			Logger.log(`Unknown command "${commandName}".`)
	}
}