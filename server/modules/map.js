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

const LEVEL_SIZE = 30 // how many rooms should be generated
const ROOMS_SIZE = 16 // size of an individual room
const ROOM_DATA_IMAGE_ROW_LEN = 4
const ROOMS = 10 // amount of rooms in rooms.png (not including the starting room)
const CELL_SIZE = 32

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

export function buildLevel() {
	var rooms = {
		"0, 0": {"type": 0, "coords": [0,0]},
		"0, 2": {"type": 0, "coords": [0,0]}
	}

	var rooms =[{"type": 0, "coords": [0,0]},{"type": 2, "coords": [0,3]}]
	var possible_room_locations = getOpenAdjacentRooms(rooms, [0,0])
}

export function getOpenAdjacentRooms(rooms, coords) {
	var emptyAdjacentRooms = []
	var adjacentCoords = [
		[coords[0]+0, coords[1]+1], // up
		[coords[0]+1, coords[1]+0], // right
		[coords[0]+0, coords[1]-1], // down
		[coords[0]-1, coords[1]+0], // left
	]
	for (adjacentCoord in adjacentCoords) {
		var coord = rooms.find((room) => room.coords[0] == coords[0] && room.coords[1] == coords[1])
		if (coord) emptyAdjacentRooms.push(coord)
	}

	return emptyAdjacentRooms
}

export function generatero