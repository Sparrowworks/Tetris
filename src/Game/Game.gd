class_name Game extends Node2D


func _on_exit_pressed() -> void:
	ComposerGD.ReplaceScene("Game","MainMenu",Global.main)
