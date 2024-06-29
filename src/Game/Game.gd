class_name Game extends Node2D

@onready var next_block_img: TextureRect = %NextBlock
@onready var time_label: Label = %Time
@onready var score_label: Label = %Score
@onready var lines_label: Label = %Lines

var time: int = 0
var score: int = 0
var lines: int = 0

func _ready() -> void:
	$Time.start()

func pause() -> void:
	pass

func reset() -> void:
	pass

func exit() -> void:
	ComposerGD.ReplaceScene("Game","MainMenu",Global.main)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		exit()

	if Input.is_action_just_pressed("pause"):
		pause()

	if Input.is_action_just_pressed("reset"):
		reset()

func _on_pause_pressed() -> void:
	pause()

func _on_reset_pressed() -> void:
	reset()

func _on_exit_pressed() -> void:
	exit()

func _on_time_timeout() -> void:
	time += 1
	time_label.text = "Time: " + str(time)

func _on_grid_update_score(s: int) -> void:
	score += s
	score_label.text = "Score: " + str(score)

func _on_grid_line_cleared() -> void:
	lines += 1
	lines_label.text = "Lines: " + str(lines)
