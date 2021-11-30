import Jimp from "jimp"
import { log, error } from "./logger.js"
import { send } from "./messages.js"
import { getTile, TileMap } from "./tiles.js"

const ROOMDATA_IMAGE_ROWLENGTH = 4 // length of rows in rooms.png
const ROOMDATA_ROOMS = 10 // amount of rooms in rooms.png
const ROOM_SIZE = 32 // size of an individual room
const ROOMS = 11 // total amount of rooms

export class Map {
	constructor (x, y, roomAmount) {
		this.x = x
		this.y = y

		var timestamp = Date.now() // used to track how long it took to generate the map

		this.tiles = new TileMap(x, y)
		
		this.rooms = [
			{type: 0, coords: [0, 0]} // starting room
		]

		for (var room = 0; room < roomAmount; room++) { // generate rooms
			this.rooms.push(getAdjacentRoom(this.rooms))
		}

		Jimp.read("./assets/rooms.png", (err, image) => {
			if (err) return error(`Failed to load rooms.png!!! Level cannot be generated Error: "${err}"`)
			
			for (const room of this.rooms) {
				this.tiles.fill(
					room.coords[0] * ROOM_SIZE + 1, // add 1 to the position because otherwise the left wall is x = -1, which cant be rendered
					room.coords[1] * ROOM_SIZE + 1,
					ROOM_SIZE,
					ROOM_SIZE,
					9
				)
			}

			surroundMap(this.tiles)

			for (const room of this.rooms) {
				var xImage = (room.type % ROOMDATA_IMAGE_ROWLENGTH) * ROOM_SIZE
				var yImage = Math.floor(room.type / ROOMDATA_IMAGE_ROWLENGTH) * ROOM_SIZE

				for (var x = 0; x < ROOM_SIZE; x++) {
					for (var y = 0; y < ROOM_SIZE; y++) {
						var pixel = Jimp.intToRGBA(image.getPixelColor(xImage + x, yImage + y))

						if (pixel.r == 0 && pixel.g == 0 && pixel.b == 0 && pixel.a == 255) { // black
							this.tiles.set(
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1,
								"wall"
							)
						}
					}
				}
			}
			log(`Generated map with ${this.tiles.all().length} tiles in ${Date.now() - timestamp}ms!`)
		})
	}
	send(ws) {
		for (const tilex of this.tiles.tiles) {
			for (const tiley in tilex) {
				if (isNaN(tilex[tiley])) continue
				send(ws, "tile_update", {
					"x": this.tiles.tiles.indexOf(tilex),
					"y": Number(tiley),
					"tile": tilex[tiley] 
				})
			}
		}
	}
}

export function getAdjacentRoom(rooms) {
	var randomRoom = rooms[rooms.length - Math.floor(Math.random() * 5)] //rooms[Math.floor(Math.random() * rooms.length)]
	if (!randomRoom) randomRoom = rooms[rooms.length - 1]
	var room
	var random = Math.floor(Math.random() * 3) // get random cardinal direction
	var type = Math.floor(Math.random() * ROOMS)
	if (type == 0) type = 1 // ignore the starting room

	switch (random) {
		case 0: // north
			room = {
				type: type,
				coords: [randomRoom.coords[0], randomRoom.coords[1] - 1]
			}
			break
		case 1: // east
			room = {
				type: type,
				coords: [randomRoom.coords[0] + 1, randomRoom.coords[1]]
			}
			break
		case 2: // south
			room = {
				type: type,
				coords: [randomRoom.coords[0], randomRoom.coords[1] + 1]
			}
			break
		case 3: // west
			room = {
				type: type,
				coords: [randomRoom.coords[0] - 1, randomRoom.coords[1]]
			}
			break
	}

	if (rooms.find(x => x.coords[0] == room.coords[0] && x.coords[1] == room.coords[1] )) { // room already exists
		room = getAdjacentRoom(rooms)
	}

	return room
}

export function surroundMap(tiles) { // surrounds the map with a wall
	for (const tile of tiles.all()) {
		if (tile.tile != getTile("floor")) return

		var tile_up = tiles.get(tile.x, tile.y - 1)
		var tile_right = tiles.get(tile.x + 1, tile.y)
		var tile_down = tiles.get(tile.x, tile.y + 1)
		var tile_left = tiles.get(tile.x - 1, tile.y)
		
		if (!tile_up) tiles.set(tile.x, tile.y - 1, "wall")
		if (!tile_right) tiles.set(tile.x + 1, tile.y, "wall")
		if (!tile_down) tiles.set(tile.x, tile.y + 1, "wall")
		if (!tile_left) tiles.set(tile.x - 1, tile.y, "wall")
	}
}