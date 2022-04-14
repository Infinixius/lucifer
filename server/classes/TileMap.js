Array.prototype.range = function(amount) {
	if (amount === undefined) return new Error("Missing argument!")
	if (typeof amount != "number") return new Error("Not a number!")

	var array = []
	for (var i = 0; i < amount; i++) {
		array.push(i)
	}
	
	return array
}

const tiles = {
	"missing": 0,
	"void": 1,

	"meta": 2,
	"meta_light": 3,
	"meta_light_block": 4,
	"meta_clip": 5,
	"meta_kill": 6,
	"meta_spawnpoint": 7,
	"meta_spawnpoint_enemy": 8,

	"floor": 9,
	"wall": 10,
	"floor_burnt": 11,
	"floor_mossy": 12,
	"floor_grasspatch": 13,

	"torch_down": 14,
	"torch_left": 15,
	"torch_right": 16,
	"torch_up": 17,

	"exit": 18,
	"keydoor": 19,
	"keydoorblue": 20,
	"keydoorred": 21,
	"keydooryellow": 22,

	"floor_skull": 23
}
module.exports.tiles = tiles

function getTile(tile) {
	if (tiles[tile]) {
		return tiles[tile]
	} else {
		return tiles["missing"]
	}
}
module.exports.getTile = getTile

module.exports.TileMap = class TileMap {
	constructor (xSize, ySize, defaultTile) {
		this.tiles = []

		for (const x of [].range(xSize)) {
			this.tiles.push([])
			for (const y of [].range(ySize)) {
				//this.tiles[x].push(getTile(defaultTile))
			}
		}
	}

	set (x, y, tile) {
		if (this.tiles.length > 0) { // ensure tilemap exists
			if (!this.tiles[x]) return // ensure x coordinate exists
			if (typeof tile == "string") {
				this.tiles[x][y] = getTile(tile)
			} else this.tiles[x][y] = tile
		}
	}

	get (x, y) {
		if (this.tiles.length > 0) { // ensure tilemap exists
			if (this.tiles[x])  {
				if (this.tiles[x][y]) {
					return this.tiles[x][y]
				}
			}
		}
	}

	fill (startX, startY, width, height, tile) {
		if (this.tiles.length > 0) { // ensure tilemap exists
			for (const x of [].range(width)) {
				for (const y of [].range(height)) {
					if (typeof tile == "string") {
						this.set(x + startX, y + startY, getTile(tile))
					} this.set(x + startX, y + startY, tile)
				}
			}
		}
	}

	all() {
		var tiles = []
		for (const x in this.tiles) {
			for (const y in this.tiles[x]) {
				if (typeof this.tiles[x][y] !== "number") continue // weird bug where functions are in the array
				tiles.push({
					x: Number(x),
					y: Number(y),
					tile: this.tiles[x][y]
				})
			}
		}
		return tiles
	}
}