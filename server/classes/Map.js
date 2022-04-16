const path = require("path")
const Jimp = require("jimp")
const { log, error } = require("../modules/logger.js")
const { getTile, TileMap } = require("./TileMap.js")
const { Chest } = require("./Chest.js")

const ROOMDATA_IMAGE_ROWLENGTH = 4 // length of rows in rooms.png
const ROOMDATA_ROOMS = 10 // amount of rooms in rooms.png
const ROOM_SIZE = 32 // size of an individual room
const ROOMS = 20 // total amount of rooms

module.exports.Map = class Map {
	constructor (x, y, roomAmount) {
		this.x = x
		this.y = y

		var timestamp = Date.now() // used to track how long it took to generate the map

		this.tiles = new TileMap(x, y)

		this.enemySpawners = []

		this.chests = []
		
		this.rooms = [
			{type: 0, coords: [0, 0]} // starting room
		]

		for (var room = 0; room < roomAmount; room++) { // generate rooms
			this.rooms.push(getAdjacentRoom(this.rooms))
		}

		this.rooms.push(getAdjacentRoom(this.rooms, true))

		var imagePath = path.join(__dirname, "/../assets/rooms.png") // this weird trick is required because you can't normally read rooms.png when a lan game is started from the client
		Jimp.read(imagePath, (err, image) => {
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
						} else if (pixel.r == 100 && pixel.g == 100 && pixel.b == 100 && pixel.a == 255) { // gray
							this.tiles.set(
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1,
								"exit"
							)
						} else if (pixel.r == 255 && pixel.g == 100 && pixel.b == 0 && pixel.a == 255) { // orange
							var rand = lime.random(1,100)
							if (rand > 65) {
								var chest = new Chest([
									(room.coords[0] * ROOM_SIZE + x + 1) * 32 + 16,
									(room.coords[1] * ROOM_SIZE + y + 1) * 32 + 16
								],
									lime.random(1,100) > 75
								)
								this.chests.push(chest)
							}
						} else if (pixel.r == 255 && pixel.g == 0 && pixel.b == 0 && pixel.a == 255) {
							this.tiles.set(
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1,
								"keydoorred"
							)
						} else if (pixel.r == 255 && pixel.g == 255 && pixel.b == 0 && pixel.a == 255) {
							this.tiles.set(
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1,
								"keydooryellow"
							)
						} else if (pixel.r == 0 && pixel.g == 0 && pixel.b == 255 && pixel.a == 255) {
							this.tiles.set(
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1,
								"keydoorblue"
							)
						} else if (pixel.r == 0 && pixel.g == 255 && pixel.b == 255 && pixel.a == 255) {
							this.enemySpawners.push([
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1
							])
						} else {
							this.tiles.set(
								room.coords[0] * ROOM_SIZE + x + 1,
								room.coords[1] * ROOM_SIZE + y + 1,
								tileModifier()
							)
						}
					}
				}
			}
			torches(this.tiles)

			Logger.log(`Level ${global.level}`)
			Logger.log("------------------------")
			log(`Generated map with ${this.tiles.all().length} tiles and ${this.rooms.length} rooms in ${Date.now() - timestamp}ms`)
			enemies.spawnEnemies(this.enemySpawners)

			clients.forEach(client => {
				this.send(client.ws)
			})
		})
	}
	send(ws) {
		for (const tilex of this.tiles.tiles) {
			for (const tiley in tilex) {
				if (isNaN(tilex[tiley])) continue
				ws.client.send("tile_update", {
					"x": this.tiles.tiles.indexOf(tilex),
					"y": Number(tiley),
					"tile": tilex[tiley] 
				})
			}
		}
		for (const chest of this.chests) {
			chest.networkUpdate(true)
		}
		ws.client.send("tile_update_done", true)
		ws.player.moveTo(128, 128)
		ws.player.networkUpdate(true)
	}
	networkUpdate() {
		for (const chest of this.chests) {
			chest.networkUpdate()
		}
	}
}

function getAdjacentRoom(rooms, exit) {
	var randomRoom = rooms[rooms.length - Math.floor(Math.random() * 5)] //rooms[Math.floor(Math.random() * rooms.length)]
	if (!randomRoom) randomRoom = rooms[rooms.length - 1]

	var room
	var random = Math.floor(Math.random() * 3) // get random cardinal direction
	
	var type = Math.floor(Math.random() * ROOMS)
	if (type == 0) type = 2 // ignore the starting room
	if (type == 1) type = 2 // ignore the exit room

	if (exit) type = 1

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
		room = getAdjacentRoom(rooms, exit)
	}

	return room
}

function surroundMap(tiles) { // surrounds the map with a wall
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

function torches(tiles) {
	for (const tile of tiles.all()) {
		if (tile.tile != getTile("wall")) continue
		const rand = lime.random(0,1000)
		if (rand < 975) continue

		var tile_up = tiles.get(tile.x, tile.y - 1)
		var tile_right = tiles.get(tile.x + 1, tile.y)
		var tile_down = tiles.get(tile.x, tile.y + 1)
		var tile_left = tiles.get(tile.x - 1, tile.y)

		if (tile_up) {
			if (tile_up == getTile("floor")) tiles.set(tile.x, tile.y - 1, "torch_down")
		}
		if (tile_right) {
			if (tile_right == getTile("floor")) tiles.set(tile.x + 1, tile.y, "torch_left")
		}
		if (tile_down) {
			if (tile_down == getTile("floor")) tiles.set(tile.x, tile.y + 1, "torch_up")
		}
		if (tile_left) {
			if (tile_left == getTile("floor")) tiles.set(tile.x - 1, tile.y, "torch_right")
		}
	}
}

function tileModifier() {
	const rand = lime.random(0,10000)
	if (rand > 9995) {
		return getTile("floor_skull")
	} else if (rand > 9800) {
		return getTile("floor_burnt")
	} else if (rand > 9700) {
		return getTile("floor_grasspatch")
	} else if (rand > 9600) {
		return getTile("floor_mossy")
	} else {
		return 9 // floor
	}
}