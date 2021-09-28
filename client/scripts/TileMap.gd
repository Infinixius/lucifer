extends TileMap

onready var tilemap = self
onready  var player = $"../KinematicBody2D"

enum Tiles {Door, Floor, Void, Wall} # enum of the different tile types

onready var rooms_texture_data = preload("res://assets/rooms.png").get_data() # load the rooms.png image

const LEVEL_SIZE = 30 # how many rooms should be generated
const ROOMS_SIZE = 8 # size of an individual room
const ROOM_DATA_IMAGE_ROW_LEN = 4
const ROOMS = 10 # amount of rooms in rooms.png (not including the starting room)
const CELL_SIZE = 32

func _ready():
	randomize()
	
	var rooms_data = build_level()
	generate_rooms(rooms_data)
	player.global_position = map_coord_to_world_pos(Vector2.ONE)

func map_coord_to_world_pos(coord): # takes list of 2 and converts it to a global position
	return tilemap.map_to_world(Vector2(coord[0], coord[1])) + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)

func build_level():
	var rooms_data = {
		str([0,0]):{"type": 0, "coords":[0,0]}
	}
	
	var possible_room_locations = get_open_adjacent_rooms(rooms_data, [0,0]) # get adjacent rooms that are open
	var generated_rooms = []
	
	for x in range(LEVEL_SIZE):
		var rand_room_loc = select_rand_room_location(possible_room_locations, rooms_data) # gets a random adjacent room
		var rand_room_type = (randi() % (ROOMS)) + 1
		print(str(rand_room_type))
		rooms_data[str(rand_room_loc)] = {"type": rand_room_type, "coords":rand_room_loc} # add room
		generated_rooms.append(rand_room_loc)
		possible_room_locations += get_open_adjacent_rooms(rooms_data, rand_room_loc)
	
	return rooms_data

func select_rand_room_location(possible_room_locations: Array, rooms_data: Dictionary): # get a random room location from the adjacent rooms
	var rand_ind = randi() % possible_room_locations.size()
	var rand_room_loc = possible_room_locations[rand_ind]
	possible_room_locations.remove(rand_ind)
	if str(rand_room_loc) in rooms_data:
		rand_room_loc = select_rand_room_location(possible_room_locations, rooms_data)
	return rand_room_loc

func get_open_adjacent_rooms(rooms_data: Dictionary, coords): # get a list of all adjacent rooms that are also open
	var empty_adjacent_rooms = []
	var adj_coords = [
		[coords[0]+0, coords[1]+1], # up
		[coords[0]+1, coords[1]+0], # right
		[coords[0]+0, coords[1]-1], # down
		[coords[0]-1, coords[1]+0], # left
	]
	for coord in adj_coords:
		if not str(coord) in rooms_data:
			empty_adjacent_rooms.append(coord)
	return empty_adjacent_rooms

func generate_rooms(rooms_data_list: Dictionary) -> void:
	var spawn_locations = {
		"door_coords": [],
		"exit_coords": [0, 0],
	}
	var ind = 0
	var walkable_floor_tiles = {}
	for room_data in rooms_data_list.values():
		var only_do_walls = ind == 0 # only want to create walls if it's the first room since that's where the player starts
		ind += 1
		var coords = room_data.coords # coordinates of this room
		
		var x_pos = coords[0] * ROOMS_SIZE
		var y_pos = coords[1] * ROOMS_SIZE
		
		var type = room_data.type
		var x_pos_img = (type % ROOM_DATA_IMAGE_ROW_LEN) * ROOMS_SIZE
		var y_pos_img = (type / ROOM_DATA_IMAGE_ROW_LEN) * ROOMS_SIZE
		
		for x in range(ROOMS_SIZE):
			for y in range(ROOMS_SIZE):
				rooms_texture_data.lock()
				var cell_data = rooms_texture_data.get_pixel(x_pos_img+x, y_pos_img+y)
				var cell_coords = [x_pos+x, y_pos+y]
				var wall_tile = false
				if cell_data == Color.black:
					tilemap.set_cell(x_pos+x, y_pos+y, Tiles.Wall)
					wall_tile = true
				if !only_do_walls:
					if cell_data == Color.red:
						pass #spawn_locations.enemy_spawn_locations.append(cell_coords)
					elif cell_data == Color.green:
						pass #spawn_locations.pickup_spawn_locations.append(cell_coords)
					elif cell_data == Color.blue:
						pass #spawn_locations.exit_coords = cell_coords
					elif cell_data == Color.magenta:
						pass #spawn_locations.door_coords.append(cell_coords)
				if !wall_tile:
					walkable_floor_tiles[str([x_pos+x, y_pos+y])] = [x_pos+x, y_pos+y]
		
		var scoords = ""
		var room_at_left = str([coords[0]-1, coords[1]]) in rooms_data_list
		var room_at_right = str([coords[0]+1, coords[1]]) in rooms_data_list
		var room_at_top = str([coords[0], coords[1]-1]) in rooms_data_list
		var room_at_bottom = str([coords[0], coords[1]+1]) in rooms_data_list
		if !room_at_left:
			tilemap.set_cell(x_pos, y_pos+3, Tiles.Wall)
			tilemap.set_cell(x_pos, y_pos+4, Tiles.Wall)
			scoords = str([x_pos, y_pos+3])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
			scoords = str([x_pos, y_pos+4])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
		if !room_at_right:
			tilemap.set_cell(x_pos+ROOMS_SIZE-1, y_pos+3, Tiles.Wall)
			tilemap.set_cell(x_pos+ROOMS_SIZE-1, y_pos+4, Tiles.Wall)
			scoords = str([x_pos+ROOMS_SIZE-1, y_pos+3])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
			scoords = str([x_pos+ROOMS_SIZE-1, y_pos+4])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
		if !room_at_top:
			tilemap.set_cell(x_pos+3, y_pos, Tiles.Wall)
			tilemap.set_cell(x_pos+4, y_pos, Tiles.Wall)
			scoords = str([x_pos+3, y_pos])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
			scoords = str([x_pos+4, y_pos])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
		if !room_at_bottom:
			tilemap.set_cell(x_pos+3, y_pos+ROOMS_SIZE-1, Tiles.Wall)
			tilemap.set_cell(x_pos+4, y_pos+ROOMS_SIZE-1, Tiles.Wall)
			scoords = str([x_pos+3, y_pos+ROOMS_SIZE-1])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)
			scoords = str([x_pos+4, y_pos+ROOMS_SIZE-1])
			if scoords in walkable_floor_tiles:
				walkable_floor_tiles.erase(scoords)

#func _process(delta):
#	pass
