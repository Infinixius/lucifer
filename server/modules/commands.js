import readline from "readline"
import Map from "../classes/Map.js"

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
})

export function consoleCommand() {
	rl.question("", message => {
		command(message)
		consoleCommand()
	})
}

export function command(string) {
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
		case "regenerate":
			global.map = new Map(300, 300, 32)
			global.map.networkUpdate()
			break
		case "summon":
			global.enemies.createEnemy([12 * 16, 12 * 16])
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
		default:
			Logger.log(`Unknown command "${commandName}".`)
	}
}