class_name Game extends Node2D

func pause() -> void:
	pass

func reset() -> void:
	pass

func exit() -> void:
	ComposerGD.ReplaceScene("Game","MainMenu",Global.main)

func _process(delta: float) -> void:
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






