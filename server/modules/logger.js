import fs from "fs"
import config from "../config.json"
import npmpackage from "../package.json"

if (!fs.existsSync(config.logsFolder)) {
	fs.mkdirSync(config.logsFolder)
}

export function timestamp() {
	return new Date().toLocaleTimeString()
}
export function datestamp() {
	return new Date().toLocaleDateString()
}

// splash
console.log(`lucifer dedicated server - version v${npmpackage.version}`)
console.log("made with <3 by infinixius, R3ggo, and ASSASSIN22")
console.log("-------------------------------------------------")

// create log file

let name = config.logsFileFormat
name = name.replace("%time", timestamp().replace(/:/g,"-")) // you can't have : in windows filenames
name = name.replace("%date", datestamp().replace(/\//g, "-")) // you can't have / in windows filenames

var file = fs.createWriteStream(name, {flags: "a+"})
file.write(`lucifer dedicated server v${npmpackage.version} log file from ${timestamp()} - ${datestamp()}\n`)
file.write("---------------------------------------------\n")

console.log(`Logging to file "${name}"`)
console.log("---------------------------------------------")

export function advlog(message, type) {
	if (!type) var type = "log"

	let log = config.logsFormat
	log = log.replace("%time", timestamp())
	log = log.replace("%date", datestamp())

	log = log.replace("%type", type)
	log = log.replace("%TYPE", type.toUpperCase())

	log = log.replace("%log", message)

	if (type != "debug") console.log(log) // do not console.log debug messages
	file.write("\n"+log)
}

export function log(message) { advlog(message, "log") }
export function error(message) { advlog(message, "error") }
export function warn(message) { advlog(message, "warn") }
export function debug(message) { advlog(message, "debug") }

export function rawerror(error) {
	console.log(error)
	file.write(error+"\n")
	file.write(error.stack+"\n")
}