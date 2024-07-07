class_name Game extends Node2D

signal pause_game()
signal unpause_game()

@onready var next_block_img: TextureRect = %NextBlock
@onready var time_label: Label = %Time
@onready var score_label: Label = %Score
@onready var lines_label: Label = %Lines
@onready var grid: Grid = %Grid
@onready var pause_text: Label = %PauseText

const BLOCK_IMAGES: Array = [
	"res://Assets/Images/i.png",
	"res://Assets/Images/j.png",
	"res://Assets/Images/l.png",
	"res://Assets/Images/o.png",
	"res://Assets/Images/s.png",
	"res://Assets/Images/t.png",
	"res://Assets/Images/z.png"
]

var time: int = 0
var score: int = 0
var lines: int = 0

var is_paused: bool = false

var is_disabled_input: bool = false

func _ready() -> void:
	$Time.start()

	var theme: int = randi_range(1,2)
	$GameTheme.stream = load("res://Assets/Audio/gameTheme" + str(theme) + ".mp3")
	$GameTheme.play()

	if not is_connected("pause_game", grid.pause_game):
		pause_game.connect(grid.pause_game)

	if not is_connected("unpause_game", grid.unpause_game):
		unpause_game.connect(grid.unpause_game)

func pause() -> void:
	is_paused = true
	$Time.stop()
	$GameTheme.stream_paused = true
	pause_game.emit()

	pause_text.text = "(P) Unpause"

func unpause() -> void:
	is_paused = false
	$Time.start()
	$GameTheme.stream_paused = false
	unpause_game.emit()

	pause_text.text = "(P)ause"

func reset() -> void:
	$GameTheme.stop()
	ComposerGD.ReloadScene("Game")

func exit() -> void:
	$GameTheme.stop()
	ComposerGD.ReplaceScene("Game","MainMenu",Global.main)

func _process(_delta: float) -> void:
	if is_disabled_input:
		return

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
		_ready()

	next_block_img.texture = load(BLOCK_IMAGES[block]) as Texture2D

func _on_grid_game_over_signal() -> void:
	$Time.stop()
	next_block_img.texture = null
