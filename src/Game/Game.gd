class_name Game extends Node2D

signal pause_game()
signal unpause_game()

@onready var next_block_img: TextureRect = %NextBlock
@onready var time_label: Label = %Time
@onready var score_label: Label = %Score
@onready var lines_label: Label = %Lines
@onready var grid: Grid = %Grid
@onready var pause_button: Button = %Pause

const BLOCK_IMAGES: Array = [
	"res://Assets/i.png",
	"res://Assets/j.png",
	"res://Assets/l.png",
	"res://Assets/o.png",
	"res://Assets/s.png",
	"res://Assets/t.png",
	"res://Assets/z.png"
]

var time: int = 0
var score: int = 0
var lines: int = 0

var is_paused: bool = false

func _ready() -> void:
	$Time.start()

	pause_game.connect(grid.pause_game)
	unpause_game.connect(grid.unpause_game)

func pause() -> void:
	is_paused = true
	$Time.stop()
	pause_game.emit()

	pause_button.text = "(P) Unpause"

func unpause() -> void:
	is_paused = false
	$Time.start()
	unpause_game.emit()

	pause_button.text = "(P)ause"

func reset() -> void:
	ComposerGD.ReloadScene("Game")

func exit() -> void:
	ComposerGD.ReplaceScene("Game","MainMenu",Global.main)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		exit()

	if Input.is_action_just_pressed("pause"):
		if is_paused:
			unpause()
		else:
			pause()

	if Input.is_action_just_pressed("reset"):
		reset()

func _on_time_timeout() -> void:
	time += 1
	time_label.text = "Time: " + str(time)

func _on_grid_update_score(s: int) -> void:
	score += s
	score_label.text = "Score: " + str(score)

func _on_grid_line_cleared() -> void:
	lines += 1
	lines_label.text = "Lines: " + str(lines)

func _on_grid_next_block_update(block: int) -> void:
	if next_block_img == null:
		await _ready

	next_block_img.texture = load(BLOCK_IMAGES[block]) as Texture2D
