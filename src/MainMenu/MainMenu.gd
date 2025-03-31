extends Node2D

@onready var version_text: Label = $CanvasLayer/Control/VersionText

func _ready() -> void:
	Global.main.play_menu_theme()

	if OS.has_feature("web"):
		$CanvasLayer/Control/Buttons/Exit.hide()

	set_version_text()

func set_version_text() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version") as String
	var how_many_zeroes: int = version.count("0")

	if how_many_zeroes == 1:
		version_text.text = "v" + version.trim_suffix(".0")
	elif how_many_zeroes > 1:
		if version.ends_with(".0.0"):
			version_text.text = "v" + version.trim_suffix(".0.0")
		else:
			version_text.text = "v" + version.trim_suffix(".0")
	else:
		version_text.text = "v" + version

func _on_play_pressed() -> void:
	Global.main.stop_menu_theme()
	Global.main.go_to("res://src/Game/Game.tscn")

func _on_settings_pressed() -> void:
	Global.main.go_to("res://src/Settings/Settings.tscn")

func _on_credits_pressed() -> void:
	Global.main.go_to("res://src/Credits/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
