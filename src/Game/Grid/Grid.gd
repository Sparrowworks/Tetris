class_name Grid extends TileMap

const MAX_X = 10
const MAX_Y = 24
const ATLAS_COORDS: Vector2i = Vector2i.ZERO
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

var active_block_coords: Array[Vector2i] = [

]

var active_block_id: int = 0

var timer:Timer

func _ready() -> void:
	clear_board()
	timer = $TetrominoTimer
	generate_new_block()

#region BOARD_FUNCTIONS

func clear_board(fast: bool = true) -> void:
	if fast:
		clear()
		for x in range(0,MAX_X):
			for y in range(0,MAX_Y):
				set_cell(0,Vector2i(x,y),BLOCK_IDS.GREY,ATLAS_COORDS)

func generate_new_block() -> void:
	timer.stop()
	var block_id: int = randi_range(0,6)
	var block_resource: Block = BLOCK_FILES[block_id]
	var block_spawn_coords: Array[Vector2i] = block_resource.SpawnCoords
	var block_color: int = block_resource.id

	for coord: Vector2i in block_spawn_coords:
		set_cell(0,coord,block_color,ATLAS_COORDS)
		active_block_coords.append(coord)

	active_block_id = block_id
	timer.start()

#endregion

#region MOVEMENT
enum LEGAL_MOVES
{
	DOWN,
	LEFT,
	RIGHT
}

func move(request: LEGAL_MOVES) -> void:
	var updated_coords: Array[Vector2i]
	match request:
		LEGAL_MOVES.DOWN:
			updated_coords = get_new_coords(Vector2i.DOWN)
			for coord: Vector2i in updated_coords:
				if coord.y > MAX_Y-1:
					generate_new_block()
					return
		LEGAL_MOVES.LEFT:
			updated_coords = get_new_coords(Vector2i.LEFT)
			for coord: Vector2i in updated_coords:
				if coord.y > MAX_X-1: return
		LEGAL_MOVES.RIGHT:
			updated_coords = get_new_coords(Vector2i.RIGHT)	
			for coord: Vector2i in updated_coords:
				if coord.y > MAX_X+1: return
		_:
			printerr("Illegal move: ", request)
			return
	update_coords(updated_coords)

func get_new_coords(vector: Vector2i) -> Array[Vector2i]:
	var new_coords: Array[Vector2i] = []

	for i in range(0,active_block_coords.size()):
		var old_coord: Vector2i = active_block_coords[i]
		new_coords.append(Vector2i(old_coord.x + vector.x, old_coord.y + vector.y))

	return new_coords

func update_coords(coords: Array[Vector2i]) -> void:
	for i in range(0,active_block_coords.size()):
		var old_coord: Vector2i = active_block_coords[i]
		active_block_coords[i] = coords[i]

		set_cell(0,old_coord,BLOCK_IDS.GREY,ATLAS_COORDS)

	for coord in active_block_coords:
		set_cell(0,coord,active_block_id,ATLAS_COORDS)

#endregion MOVEMENT

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		_on_tetromino_timer_timeout()
	elif Input.is_action_just_pressed("left"):
		move(LEGAL_MOVES.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(LEGAL_MOVES.RIGHT)

func _on_tetromino_timer_timeout() -> void:
	move(LEGAL_MOVES.DOWN)
	print("i moved")
