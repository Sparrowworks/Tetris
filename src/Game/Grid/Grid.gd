class_name Grid extends TileMapLayer

signal line_cleared(amount: int)
signal update_score(score: int)
signal next_block_update(block: int)

signal game_over_music()
signal game_over_signal()

const MAX_X = 10
const MAX_Y = 24
const ATLAS_COORDS: Vector2i = Vector2i.ZERO
const LINE_SCORE: int = 50
const MAX_ROTATE_TRIES: int = 10

enum BLOCK_IDS
{
	BLUE = 0,
	PINK = 1,
	ORANGE = 2,
	YELLOW = 3,
	GREEN = 4,
	PURPLE = 5,
	RED = 6,
	GREY = 7,
	BLACK = 8,
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

var ghost_block_coords: Array = [

]

var active_block_id: int = 0
var active_rotation_id: int = 0
var rotation_tries: int = 0
var next_block_id: int = -1

var line_multiplier: float = 1.0
var line_clear_difficulty: int = 0
var difficulty_update: int = 2

var tetromino_bag: Array = []

var is_game_over: bool = false

func _ready() -> void:
	clear_board()
	generate_bag()
	generate_new_block()

func pause_game() -> void:
	set_process(false)
	move_timer.stop()

func unpause_game() -> void:
	set_process(true)
	move_timer.start()

#region BOARD_FUNCTIONS

func check_for_game_over() -> bool:
	# Checks if the placed blocks are blocking the spawn of a new block
	for x in range(0,MAX_X):
		for y in range(0,5):
			var vector: Vector2i = Vector2i(x,y)
			if get_cell_source_id(vector) != BLOCK_IDS.GREY and not active_block_coords.has(vector):
				return true

	return false

func game_over() -> void:
	game_over_music.emit()
	move_timer.paused = true

	$GameOver.play()

	for y in range(23,-1,-1):
		clear_line_game_over(y)
		await get_tree().create_timer(0.1).timeout

	game_over_signal.emit()

func clear_line_game_over(y: int) -> void:
	for x in range(0,int(MAX_X/2)+1):
		set_cell(Vector2i(x,y),-1)
		set_cell(Vector2i(MAX_X-x,y),-1)
		await get_tree().create_timer(0.05).timeout

func clear_board() -> void:
	for x in range(0,MAX_X):
		for y in range(0,MAX_Y):
			set_cell(Vector2i(x,y),BLOCK_IDS.GREY,ATLAS_COORDS)

func check_for_lines_to_clear() -> void:
	var lines: Array = []

	# A line to clear is a line which has all spaces taken in a row
	for y in range(MAX_Y-1, -1, -1):
		for x in range(0, MAX_X):
			if get_cell_source_id(Vector2i(x,y)) == BLOCK_IDS.GREY:
				break

			if x == MAX_X-1:
				lines.append(y)

	if not lines.is_empty():
		clear_lines(lines)
	else:
		generate_new_block()

func is_line_empty(y: int) -> bool:
	for x in range(0, MAX_X):
		if get_cell_source_id(Vector2i(x,y)) != BLOCK_IDS.GREY:
			return false

	return true

func update_difficulty() -> void:
	difficulty_update += 1

	move_timer.stop()
	move_timer.wait_time = wrapf(move_timer.wait_time * 0.985,0.25,1.0)

func clear_lines(lines: Array) -> void:
	line_cleared.emit(lines.size())
	line_multiplier += 0.05

	if not $LineClear.playing:
		$LineClear.play()

	update_score.emit(int(LINE_SCORE * line_multiplier * lines.size()))

	line_clear_difficulty += 1
	if line_clear_difficulty == difficulty_update:
		update_difficulty()

	for i in range(lines.size()-1,-1,-1):
		var line: int = lines[i]

		# Remove the filled line.
		for x in range(0,int(MAX_X/2)+1):
			set_cell(Vector2i(x,line),BLOCK_IDS.GREY,ATLAS_COORDS)
			set_cell(Vector2i(wrap(MAX_X-x,0,10),line),BLOCK_IDS.GREY,ATLAS_COORDS)
			await get_tree().create_timer(0.025).timeout

		# Move down all the blocks that are now floating
		for y in range(line,0,-1):
			for x in range(0, MAX_X):
				var cell_upwards: int = get_cell_source_id(Vector2i(x,y-1))

				set_cell(Vector2i(x,y),cell_upwards,ATLAS_COORDS)

	generate_new_block()

func generate_bag() -> void:
	# Determines the spawn order of upcoming tetrominos.
	randomize()
	tetromino_bag = range(0,6)
	tetromino_bag.shuffle()

func generate_new_block() -> void:
	# Do not draw a next block if its time to game over
	if check_for_game_over():
		move_timer.paused = true
		is_game_over = true
		game_over()
		return

	clear_previous_ghost()
	ghost_block_coords.clear()

	var block_id: int

	# Grab a tetromino to spawn
	if next_block_id == -1:
		block_id = tetromino_bag.pop_front()
	else:
		block_id = next_block_id

	if tetromino_bag == []:
		generate_bag()

	next_block_id = tetromino_bag.pop_front()
	next_block_update.emit(next_block_id)

	# Draw a tetromino and a ghost block
	var block_resource: Block = BLOCK_FILES[block_id]
	var block_spawn_coords: Array = block_resource.SpawnCoords[0]
	var block_color: int = block_resource.ID

	active_block_coords.clear()

	for i in range(0,4):
		var coord: Vector2i = block_spawn_coords[i]
		var new_coord: Vector2i = Vector2i(coord.x+int(MAX_X/2)-1,coord.y)
		set_cell(new_coord,block_color,ATLAS_COORDS)
		active_block_coords.append(new_coord)

	active_block_id = block_id
	active_rotation_id = 0
	rotation_tries = 0

	draw_ghost_block()

	# Place the tetromino on screen (initial grid coordinates are off-screen).
	move_down()
	move_down()

#endregion

#region MOVEMENT
func move_down() -> void:
	move_timer.stop()
	var updated_coords: Array = get_new_coords(Vector2i.DOWN, active_block_coords)

	if can_move_down(updated_coords):
		$PieceMove.play()
		update_coords(active_block_coords, updated_coords)
	else:
		$PieceFail.play()
		check_for_lines_to_clear()
		update_score.emit(active_block_id+randi_range(1,6))

	move_timer.start()

func move_left() -> void:
	var updated_coords: Array= get_new_coords(Vector2i.LEFT, active_block_coords)

	if can_move_left(updated_coords):
		update_coords(active_block_coords, updated_coords)
		draw_ghost_block()

func move_right() -> void:
	var updated_coords: Array = get_new_coords(Vector2i.RIGHT, active_block_coords)

	if can_move_right(updated_coords):
		update_coords(active_block_coords, updated_coords)
		draw_ghost_block()

func get_new_coords(vector: Vector2i, coords: Array) -> Array:
	var new_coords: Array = []

	for i in range(0,coords.size()):
		var old_coord: Vector2i = coords[i]
		new_coords.append(Vector2i(old_coord.x + vector.x, old_coord.y + vector.y))

	return new_coords

# Replaces the old coordinates of the block with new ones
func update_coords(old_coords: Array, new_coords: Array) -> void:
	for i in range(0,old_coords.size()):
		var old_coord: Vector2i = old_coords[i]
		active_block_coords[i] = new_coords[i]

		set_cell(old_coord,BLOCK_IDS.GREY,ATLAS_COORDS)

	for coord: Vector2i in active_block_coords:
		set_cell(coord,active_block_id,ATLAS_COORDS)

func rotate_block(direction: int, coords: Array) -> void:
	rotation_tries += 1

	# If rotation fails after several attempts, it's considered impossible.
	if rotation_tries >= MAX_ROTATE_TRIES:
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

	# Calculate the rotated block's new coordinates
	for i in range(0,coords.size()):
		var rot_coord: Vector2i = rotation_array[i]
		var new_coord: Vector2i = Vector2i(pivot_coord.x+rot_coord.x,pivot_coord.y+rot_coord.y)

		if is_cell_taken(new_coord, active_block_coords):
			return

		new_coords.append(new_coord)

	# If rotation fails due to limited space, keep increasing the rotation until it succeeds.
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
	$PieceRotate.play()
	update_coords(active_block_coords, new_coords)
	draw_ghost_block()

#endregion MOVEMENT

#region VERIFY_MOVEMENT
func can_rotate_left(coord: Vector2i) -> bool:
	return coord.x >= 0

func can_rotate_right(coord: Vector2i) -> bool:
	return coord.x < MAX_X

func can_rotate_down(coord: Vector2i) -> bool:
	return coord.y < MAX_Y-1

func is_cell_taken(coord: Vector2i, coords_to_check: Array) -> bool:
	# A cell is taken when its not colored and not a ghost block
	if coord in coords_to_check: return false

	var tile: int = get_cell_source_id(coord)

	if tile == BLOCK_IDS.GREY or tile == -1 or tile == BLOCK_IDS.BLACK:
		return false

	return true

func can_move_down(coords: Array) -> bool:
	for coord: Vector2i in coords:
		if coord.y > MAX_Y-1:
			return false

		if is_cell_taken(coord, active_block_coords):
			return false

	return true

func can_move_left(coords: Array) -> bool:
	for coord: Vector2i in coords:
		if coord.x < 0:
			return false

		if is_cell_taken(coord, active_block_coords):
			return false

	return true

func can_move_right(coords: Array) -> bool:
	for coord: Vector2i in coords:
		if coord.x >= MAX_X:
			return false

		if is_cell_taken(coord, active_block_coords):
			return false

	return true

#endregion

#region GHOST_BLOCK
func clear_previous_ghost() -> void:
	for coord: Vector2i in ghost_block_coords:
		if coord in active_block_coords:
			continue

		set_cell(coord,BLOCK_IDS.GREY,ATLAS_COORDS)

func update_ghost_coords() -> void:
	# Draws the ghost block based on the lowest possible position
	ghost_block_coords = active_block_coords

	while true:
		var move_coords: Array = get_new_coords(Vector2i.DOWN, ghost_block_coords)
		if can_move_down(move_coords):
			ghost_block_coords = move_coords
		else:
			break

func draw_ghost_block() -> void:
	# A ghost block is a block indicating where the piece is going to land
	clear_previous_ghost()

	update_ghost_coords()

	for coord: Vector2i in ghost_block_coords:
		if coord in active_block_coords:
			continue

		set_cell(coord, BLOCK_IDS.BLACK, ATLAS_COORDS)

#endregion

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		move_down()

	if Input.is_action_just_pressed("drop"):
		$PieceDrop.play()
		move_timer.stop()

		# Keep moving the piece down until it reaches a blockade
		while true:
			var move_coords: Array = get_new_coords(Vector2i.DOWN, active_block_coords)
			if can_move_down(move_coords):
				update_coords(active_block_coords, move_coords)
			else:
				break

		update_score.emit(int((active_block_id+randi_range(1,6)/2)))
		check_for_lines_to_clear()

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
