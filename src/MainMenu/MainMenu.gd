extends Node2D

func _on_play_pressed() -> void:
	ComposerGD.ReplaceScene("MainMenu","Game",Global.main)

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_credits_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()






