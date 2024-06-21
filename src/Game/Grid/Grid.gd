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

func clear_board(fast: bool = true) -> void:
	if fast:
		clear()
		for x in range(0,MAX_X):
			for y in range(0,MAX_Y):
				set_cell(0,Vector2i(x,y),BLOCK_IDS.GREY,ATLAS_COORDS)

func generate_new_block():
	var block_id: int = randi_range(0,6)
	var block_resource = BLOCK_FILES[block_id]
	var block_spawn_coords = block_resource.SpawnCoords
	var block_color: int = block_resource.id

	for coord in block_spawn_coords:
		set_cell(0,coord,block_color,ATLAS_COORDS)
		active_block_coords.append(coord)

	active_block_id = block_id

func move_down() -> void:
	var new_coords: Array[Vector2i] = []
	print(active_block_coords)

	for x in range(0,active_block_coords.size()):
		var old_coord = active_block_coords[x]
		var new_coord: Vector2i = Vector2i(old_coord.x,old_coord.y+1)

		set_cell(0,old_coord,BLOCK_IDS.GREY,ATLAS_COORDS)
		force_update()
		set_cell(0,new_coord,active_block_id,ATLAS_COORDS)
		new_coords.append(new_coord)

	active_block_coords = new_coords
	print(active_block_coords)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		move_down()

func pause():
	pass

func unpause():
	pass
