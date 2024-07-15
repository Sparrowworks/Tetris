extends Node2D

func _ready() -> void:
	Global.main.play_menu_theme()

func _on_play_pressed() -> void:
	Global.main.stop_menu_theme()
	Global.main.cross_fade("MainMenu","Game")

func _on_settings_pressed() -> void:
	Global.main.cross_fade("MainMenu","Settings")

func _on_credits_pressed() -> void:
	Global.main.cross_fade("MainMenu","Credits")

func _on_exit_pressed() -> void:
	get_tree().quit()






