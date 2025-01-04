extends Node2D

func _ready() -> void:
	Global.main.play_menu_theme()

	if OS.has_feature("web"):
		$CanvasLayer/Control/Buttons/Exit.hide()

func _on_play_pressed() -> void:
	Global.main.stop_menu_theme()
	Global.main.go_to("res://src/Game/Game.tscn")

func _on_settings_pressed() -> void:
	Global.main.go_to("res://src/Settings/Settings.tscn")

func _on_credits_pressed() -> void:
	Global.main.go_to("res://src/Credits/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
