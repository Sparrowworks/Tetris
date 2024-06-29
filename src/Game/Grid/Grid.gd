class_name Grid extends TileMap

signal line_cleared()
signal update_score(score: int)
signal next_block_update(block: int)

const MAX_X = 10
const MAX_Y = 24
const ATLAS_COORDS: Vector2i = Vector2i.ZERO
const LINE_SCORE: int = 50

enum BLOCK_IDS
{
	BLUE = 0,
	PINK = 1,
	ORANGE = 2,
	YELLOW = 3,
	GREEN = 4,
	PURPLE = 5,
	RED = 6,
	GREY = 7
}

const BLOCK_FILES: Array[Block] = [
	preload("res://src/Game/Blocks/i_block.tres"),
	preload("res://src/Game/Blocks/j_block.tres"),
	preload("res://src/Game/Blocks/l_block.tres"),
	preload("res://src/Game/Blocks/o_block.tres"),
	preload("res://src/Game/Blocks/s_block.tres"),
	preload("res://src/Game/Blocks/t_block.tres"),
	preload("res://src/Game/Blocks/z_block.tres")
]

@onready var move_timer: Timer = $MoveTimer

var active_block_coords: Array = [

]

var active_block_id: int = 0
var active_rotation_id: int = 0
var rotation_tries: int = 0
var next_block_id: int = -1

var hard_dropped: bool = false

var line_multiplier: float = 1.0
var line_clear_difficulty: int = 0
var difficulty_update: int = 2

func _ready() -> void:
	clear_board()
	generate_new_block()

func pause_game() -> void:
	set_process(false)
	move_timer.stop()

func unpause_game() -> void:
	set_process(true)
	move_timer.start()

#region BOARD_FUNCTIONS

func clear_board(fast: bool = true) -> void:
	if fast:
		clear()
		for x in range(0,MAX_X):
			for y in range(0,MAX_Y):
				set_cell(0,Vector2i(x,y),BLOCK_IDS.GREY,ATLAS_COORDS)

func check_line_clear() -> void:
	for y in range(MAX_Y-1, -1, -1):
		for x in range(0, MAX_X):
			if get_cell_source_id(0,Vector2i(x,y)) == BLOCK_IDS.GREY:
				break

			if x == MAX_X-1:
				clear_line(y)

func update_difficulty() -> void:
	difficulty_update += 1

	move_timer.stop()
	move_timer.wait_time = wrapf(move_timer.wait_time * 0.985,0.25,1.0)

func clear_line(line_y: int) -> void:
	line_cleared.emit()
	line_multiplier += 0.05

	update_score.emit(int(LINE_SCORE * line_multiplier))

	line_clear_difficulty += 1
	if line_clear_difficulty == difficulty_update:
		update_difficulty()

	for x in range(0,MAX_X):
		set_cell(0,Vector2i(x,line_y),BLOCK_IDS.GREY,ATLAS_COORDS)

	for y in range(line_y,0,-1):
		for x in range(0, MAX_X):
			var cell_upwards: int = get_cell_source_id(0,Vector2i(x,y-1))
			set_cell(0,Vector2i(x,y),cell_upwards,ATLAS_COORDS)

	check_line_clear()

func generate_new_block() -> void:
	check_line_clear()

	var block_id: int

	if next_block_id == -1:
		block_id = randi_range(0,6)
	else:
		block_id = next_block_id

	next_block_id = randi_range(0,6)
	next_block_update.emit(next_block_id)

	var block_resource: Block = BLOCK_FILES[block_id]
	var block_spawn_coords: Array = block_resource.SpawnCoords[0]
	var block_color: int = block_resource.ID

	active_block_coords.clear()

	for i in range(0,4):
		var coord: Vector2i = block_spawn_coords[i]
		var new_coord: Vector2i = Vector2i(coord.x+int(MAX_X/2)-1,coord.y)
		set_cell(0,new_coord,block_color,ATLAS_COORDS)
		active_block_coords.append(new_coord)

	hard_dropped = false
	active_block_id = block_id
	active_rotation_id = 0
	rotation_tries = 0

	move_down()
	move_down()

#endregion

#region MOVEMENT
func move_down() -> void:
	move_timer.stop()
	var updated_coords: Array = get_new_coords(Vector2i.DOWN, active_block_coords)

	if can_move_down(updated_coords):
		update_coords(active_block_coords, updated_coords)
	else:
		generate_new_block()
		update_score.emit(active_block_id+randi_range(1,6))

	move_timer.start()

func move_left() -> void:
	var updated_coords: Array= get_new_coords(Vector2i.LEFT, active_block_coords)

	if can_move_left(updated_coords):
		update_coords(active_block_coords, updated_coords)

func move_right() -> void:
	var updated_coords: Array = get_new_coords(Vector2i.RIGHT, active_block_coords)

	if can_move_right(updated_coords):
		update_coords(active_block_coords, updated_coords)

func get_new_coords(vector: Vector2i, coords: Array) -> Array:
	var new_coords: Array = []

	for i in range(0,coords.size()):
		var old_coord: Vector2i = coords[i]
		new_coords.append(Vector2i(old_coord.x + vector.x, old_coord.y + vector.y))

	return new_coords

func update_coords(old_coords: Array, new_coords: Array) -> void:
	for i in range(0,old_coords.size()):
		var old_coord: Vector2i = old_coords[i]
		active_block_coords[i] = new_coords[i]

		set_cell(0,old_coord,BLOCK_IDS.GREY,ATLAS_COORDS)

	for coord: Vector2i in active_block_coords:
		set_cell(0,coord,active_block_id,ATLAS_COORDS)

#endregion MOVEMENT

#region VERIFY_MOVEMENT
func can_rotate_left(coord: Vector2i) -> bool:
	return coord.x >= 0

func can_rotate_right(coord: Vector2i) -> bool:
	return coord.x < MAX_X

func can_rotate_down(coord: Vector2i) -> bool:
	return coord.y < MAX_Y-1

func is_tile_taken(coord: Vector2i, coords_to_check: Array) -> bool:
	if coord in coords_to_check: return false

	var tile: int = get_cell_source_id(0,coord)

	if tile == BLOCK_IDS.GREY or tile == -1:
		return false

	return true

func can_move_down(coords: Array) -> bool:
	for coord: Vector2i in coords:
		if coord.y > MAX_Y-1:
			return false

		if is_tile_taken(coord, active_block_coords):
			return false

	return true

func can_move_left(coords: Array) -> bool:
	for coord: Vector2i in coords:
		if coord.x < 0:
			return false

		if is_tile_taken(coord, active_block_coords):
			return false

	return true

func can_move_right(coords: Array) -> bool:
	for coord: Vector2i in coords:
		if coord.x >= MAX_X:
			return false

		if is_tile_taken(coord, active_block_coords):
			return false

	return true

#endregion

func rotate_block(direction: int, coords: Array) -> void:
	rotation_tries += 1

	if rotation_tries == 6:
		return

	var new_rotation_id: int = active_rotation_id
	var block_file: Block = BLOCK_FILES[active_block_id]

	new_rotation_id += direction

	if new_rotation_id >= block_file.SpawnCoords.size():
		new_rotation_id = 0
	elif new_rotation_id < 0:
		new_rotation_id = block_file.SpawnCoords.size()-1

	var rotation_array: Array = block_file.SpawnCoords[new_rotation_id]
	var new_coords: Array = []

	var pivot_coord: Vector2i = coords[rotation_array[4]]

	for i in range(0,coords.size()):
		var rot_coord: Vector2i = rotation_array[i]
		var new_coord: Vector2i = Vector2i(pivot_coord.x+rot_coord.x,pivot_coord.y+rot_coord.y)

		if is_tile_taken(new_coord, active_block_coords):
			return

		new_coords.append(new_coord)

	for coord: Vector2i in new_coords:
		if not can_rotate_left(coord):
			rotate_block(direction, get_new_coords(Vector2i.RIGHT, coords))
			return

		if not can_rotate_right(coord):
			rotate_block(direction, get_new_coords(Vector2i.LEFT, coords))
			return

		if not can_rotate_down(coord):
			rotate_block(direction, get_new_coords(Vector2i.UP, coords))
			return

	active_rotation_id = new_rotation_id
	rotation_tries = 0
	update_coords(active_block_coords, new_coords)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		move_down()

	if Input.is_action_just_pressed("drop"):
		hard_dropped = true

		move_timer.stop()

		while true:
			var move_coords: Array = get_new_coords(Vector2i.DOWN, active_block_coords)
			if can_move_down(move_coords):
				update_coords(active_block_coords, move_coords)
			else:
				break

		generate_new_block()

	if Input.is_action_just_pressed("left"):
		move_left()
	elif Input.is_action_just_pressed("right"):
		move_right()

	if Input.is_action_just_pressed("rotate_clockwise"):
		rotate_block(1, active_block_coords)
	elif Input.is_action_just_pressed("rotate_counter"):
		rotate_block(-1, active_block_coords)

func _on_move_timer_timeout() -> void:
	move_down()
