import fs from "fs"
import config from "../config.json"
import npmpackage from "../package.json"

if (!fs.existsSync("./logs")) {
	fs.mkdirSync("./logs")
}

export function timestamp() {
	return new Date().toLocaleTimeString()
}
export function datestamp() {
	return new Date().toLocaleDateString()
}

// splash
console.log("lucifer dedicated server - version v" + npmpackage.version)
console.log("-------------------------------------")

// create log file

let name = config.logs_file_format
name = name.replace("%time", timestamp().replace(/:/g,"-")) // you can't have : in windows filenames
name = name.replace("%date", datestamp().replace(/\//g, "-")) // you can't have / in windows filenames

var file = fs.createWriteStream(name, {flags: "a+"})
file.write("ylp dedicated server log file from "+timestamp()+" - "+datestamp()+"\n")
file.write("---------------------------------------------\n")

console.log(`Logging to file "${name}"`)
console.log("---------------------------------------------")

export function log(message, type) {
	if (!type) var type = "log"

	let log = config.logs_format
	log = log.replace("%time", timestamp())
	log = log.replace("%date", datestamp())

	log = log.replace("%type", type)
	log = log.replace("%TYPE", type.toUpperCase())

	log = log.replace("%log", message)

	console.log(log)
	file.write("\n"+log)
}

export function error(message) { log(message, "error") }
export function warn(message) { log(message, "warn") }
export function debug(message) { log(message, "debug") }