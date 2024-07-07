extends Node2D

func _ready() -> void:
	Global.main.play_menu_theme()

func _on_play_pressed() -> void:
	Global.main.stop_menu_theme()
	ComposerGD.ReplaceScene("MainMenu","Game",Global.main)

func _on_settings_pressed() -> void:
	ComposerGD.ReplaceScene("MainMenu","Settings",Global.main)

func _on_credits_pressed() -> void:
	ComposerGD.ReplaceScene("MainMenu","Credits",Global.main)

func _on_exit_pressed() -> void:
	get_tree().quit()






