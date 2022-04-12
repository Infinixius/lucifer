var dgram = require("dgram")

var foundServers = []

const sock = dgram.createSocket("udp4", (msg, peer) => {
	if (peer.family != "IPv4") return

	var string = msg.toString()
	var data = string.split("||")
	
	if (data[0] == "LuciferDiscovered") {
		foundServers.push(data[1])
		console.log(data[1])
	}
})

sock.bind(6668)

var client = dgram.createSocket("udp4")

client.send("LuciferDiscovery", 0, "LuciferDiscovery".length, 6667, "192.168.1.255", function(err, bytes) {
	client.close()
})

setTimeout(() => {
	if (foundServers.length == 0) {
		console.log("NoServersFound")
	}
	process.exit()
}, 5000)