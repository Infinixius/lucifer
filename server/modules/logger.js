const fs = require("fs")
const util = require("util")
const config = require("../config.json")
const npmpackage = require("../package.json")

if (!fs.existsSync(config.logsFolder)) {
	fs.mkdirSync(config.logsFolder)
}

function timestamp() {
	return new Date().toLocaleTimeString()
}
function datestamp() {
	return new Date().toLocaleDateString()
}

module.exports.timestamp = timestamp
module.exports.datestamp = datestamp

// splash
console.log(".__                  .__   _____                \n|  |   __ __   ____  |__|_/ ____\\ ____ _______  \n|  |  |  |  \\_/ ___\\ |  |\\   __\\_/ __ \\\\_  __ \\ \n|  |__|  |  /\\  \\___ |  | |  |  \\  ___/ |  | \\/ \n|____/|____/  \\___  >|__| |__|   \\___  >|__|    \n                  \\/                 \\/         \n                                                ")
console.log(`lucifer ${process.argv.includes("--langame") ? "lan" : "dedicated"} server - version v${npmpackage.version}`)
console.log("made with <3 by infinixius, R3ggo, and ASSASSIN22")
console.log("-------------------------------------------------")

// create log file

let name = config.logsFileFormat
name = name.replace("%time", timestamp().replace(/:/g,"-")) // you can't have : in windows filenames
name = name.replace("%date", datestamp().replace(/\//g, "-")) // you can't have / in windows filenames

var file = fs.createWriteStream(name, {flags: "a+"})

file.write(`lucifer ${process.argv.includes("--langame") ? "lan" : "dedicated"} server v${npmpackage.version} log file from ${timestamp()} - ${datestamp()}\n`)
file.write("---------------------------------------------\n")

console.log(`Logging to file "${name}"`)
console.log("---------------------------------------------")

/* functions */

function advlog(message, type) {
	if (message.toString().includes(`message with type "ping":`)) return // do not log pings
	if (!type) var type = "log"

	let log = config.logsFormat
	log = log.replace("%time", timestamp())
	log = log.replace("%date", datestamp())

	log = log.replace("%type", type)
	log = log.replace("%TYPE", type.toUpperCase())

	log = log.replace("%log", util.format(message))

	if (type != "debug") console.log(log) // do not console.log debug messages
	file.write("\n"+log)
}

function log(message) { advlog(message, "log") }
function error(message) { advlog(message, "error") }
function warn(message) { advlog(message, "warn") }
function debug(message) { advlog(message, "debug") }

function rawerror(error) {
	console.log(error)
	file.write(error+"\n")
	file.write(error.stack+"\n")
}

module.exports.advlog = advlog

module.exports.log = log
module.exports.error = error
module.exports.warn = warn
module.exports.debug = debug

module.exports.rawerror = rawerror