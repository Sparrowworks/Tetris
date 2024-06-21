@tool
class_name Tetrimino extends Node2D

@export_enum("I","J","L","O","S","T","Z") var BLOCK_TYPE: int = 0:
	set(val):
		BLOCK_TYPE = val
		draw_new_block()

@onready var block_1: Block = $Block1
@onready var block_2: Block = $Block2
@onready var block_3: Block = $Block3
@onready var block_4: Block = $Block4
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not is_in_group("active"):
		set_process(false)

	if Input.is_action_just_pressed("down"):
		global_position = Vector2(global_position.x,global_position.y+Global.BLOCK_SIZE)

	if Input.is_action_just_pressed("left"):
		global_position = Vector2(global_position.x-Global.BLOCK_SIZE,global_position.y)
	elif Input.is_action_just_pressed("right"):
		global_position = Vector2(global_position.x+Global.BLOCK_SIZE,global_position.y)

func draw_new_block() -> void:
	if block_1 == null or block_2 == null or block_3 == null or block_4 == null:
		await ready

	match BLOCK_TYPE:
		0:
			block_1.animation = "Blue"
			block_2.animation = "Blue"
			block_3.animation = "Blue"
			block_4.animation = "Blue"

			collision_shape_2d.shape = Global.SHAPE_I

			block_1.position = Vector2(45,-45)
			block_2.position = Vector2(45,135)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(45,225)
		1:
			block_1.animation = "Pink"
			block_2.animation = "Pink"
			block_3.animation = "Pink"
			block_4.animation = "Pink"

			collision_shape_2d.shape = Global.SHAPE_J

			block_1.position = Vector2(135,-45)
			block_2.position = Vector2(135,45)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(-45,45)
		2:
			block_1.animation = "Orange"
			block_2.animation = "Orange"
			block_3.animation = "Orange"
			block_4.animation = "Orange"

			collision_shape_2d.shape = Global.SHAPE_L

			block_1.position = Vector2(-45,-45)
			block_2.position = Vector2(135,45)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(-45,45)
		3:
			block_1.animation = "Yellow"
			block_2.animation = "Yellow"
			block_3.animation = "Yellow"
			block_4.animation = "Yellow"

			collision_shape_2d.shape = Global.SHAPE_O

			block_1.position = Vector2(-45,-45)
			block_2.position = Vector2(45,-45)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(-45,45)
		4:
			block_1.animation = "Green"
			block_2.animation = "Green"
			block_3.animation = "Green"
			block_4.animation = "Green"

			collision_shape_2d.shape = Global.SHAPE_S

			block_1.position = Vector2(135,-45)
			block_2.position = Vector2(45,-45)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(-45,45)
		5:
			block_1.animation = "Purple"
			block_2.animation = "Purple"
			block_3.animation = "Purple"
			block_4.animation = "Purple"

			collision_shape_2d.shape = Global.SHAPE_T

			block_1.position = Vector2(135,45)
			block_2.position = Vector2(45,-45)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(-45,45)
		6:
			block_1.animation = "Red"
			block_2.animation = "Red"
			block_3.animation = "Red"
			block_4.animation = "Red"

			collision_shape_2d.shape = Global.SHAPE_Z

			block_1.position = Vector2(135,45)
			block_2.position = Vector2(45,-45)
			block_3.position = Vector2(45,45)
			block_4.position = Vector2(-45,-45)

