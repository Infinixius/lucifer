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
	"floor_mossy": 12
}

export function tile(tile) {
	if (tiles[tile]) {
		return tiles[tile]
	} else {
		return tiles["missing"]
	}
}