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
		case "ce":
			global.enemies.createEnemy([8,8])
			break
		default:
			Logger.log(`Unknown command "${commandName}".`)
	}
}