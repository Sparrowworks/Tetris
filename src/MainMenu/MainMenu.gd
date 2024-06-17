extends Node2D

func _on_play_pressed() -> void:
	ComposerGD.ReplaceScene("MainMenu","Game",Global.main)


func _on_exit_pressed() -> void:
	get_tree().quit()
