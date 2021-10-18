import { send } from "./messages.js"
import { tile } from "./tiles.js"

Array.prototype.range = function(amount) {
	if (amount === undefined) return new Error("Missing argument!")
	if (typeof amount != "number") return new Error("Not a number!")

	var array = []
	for (var i = 0; i < amount; i++) {
		array.push(i)
	}
	
	return array
}

class Map {
	constructor (x, y) {
		this.x = x
		this.y = y
		this.tiles = []

		for (const tilex of [].range(x)) {
			if (typeof tilex != "number") return // weird bug where functions are in [].range(x)
			this.tiles.push([].range(y))
		}
	}
}

var currentMap = new Map(100,100)

export function sendMap(ws) {
	for (const tilex of currentMap.tiles) {
		for (const tiley in tilex) {
			if (isNaN(tilex[tiley])) continue
			send(ws, "tile_update", {
				"x": currentMap.tiles.indexOf(tilex),
				"y": Number(tiley),
				"tile": tilex[tiley]
			})
		}
	}
}