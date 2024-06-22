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

func _ready() -> void:
	clear_board()
	generate_new_block()

#region BOARD_FUNCTIONS

func clear_board(fast: bool = true) -> void:
	if fast:
		clear()
		for x in range(0,MAX_X):
			for y in range(0,MAX_Y):
				set_cell(0,Vector2i(x,y),BLOCK_IDS.GREY,ATLAS_COORDS)

func generate_new_block() -> void:
	var block_id: int = 3
	var block_resource: Block = BLOCK_FILES[block_id]
	var block_spawn_coords: Array[Vector2i] = block_resource.SpawnCoords
	var block_color: int = block_resource.id

	for coord: Vector2i in block_spawn_coords:
		set_cell(0,coord,block_color,ATLAS_COORDS)
		active_block_coords.append(coord)

	active_block_id = block_id

#endregion

#region MOVEMENT
func move_down() -> void:
	var updated_coords: Array[Vector2i] = get_new_coords(Vector2i.DOWN)

	if can_move_down(updated_coords):
		update_coords(updated_coords)

#func move_left() -> void:
	#update_coords(Vector2i.LEFT)
#
#func move_right() -> void:
	#update_coords(Vector2i.RIGHT)

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

#region VERIFY_MOVEMENT
func can_move_down(coords: Array[Vector2i]) -> bool:
	for coord: Vector2i in coords:
		if coord.y > MAX_Y-1:
			return false

	return true

#endregion

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		move_down()

	#if Input.is_action_just_pressed("left"):
		#move_left()
	#elif Input.is_action_just_pressed("right"):
		#move_right()

