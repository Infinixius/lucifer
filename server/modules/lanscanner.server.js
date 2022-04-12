const dgram = require("dgram")
const config = require("../config.json")
var localIP
require("local-ipv4-address")().then(res => { localIP = res })

const sock = dgram.createSocket("udp4", (msg, peer) => {
	if (peer.family != "IPv4") return

	var string = msg.toString()
	if (string.startsWith("LuciferDiscovery")) {
		Logger.log(`Discovered LAN client at "${peer.address}:${peer.port}"`)
		var client = dgram.createSocket("udp4")
		var str = `LuciferDiscovered||${localIP}`

		client.send(str, 0, str.length, config.rediscoveryPort, peer.address, function(err, bytes) {
			client.close()
		})
	}
})

sock.bind(config.discoveryPort, () => {
	Logger.log(`Started LAN discovery on port ${config.discoveryPort}`)
})