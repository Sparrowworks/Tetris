extends Node2D

@onready var menu_theme: AudioStreamPlayer = $MenuTheme

func _ready() -> void:
	randomize()

	Global.main = self

	ComposerGD.AddScene("Game","res://src/Game/Game.tscn",
	{
		"instant_load":true,
		"scene_parent":self
	})

	ComposerGD.AddScene("MainMenu","res://src/MainMenu/MainMenu.tscn",
	{
		"instant_load":true,
		"instant_create":true,
		"scene_parent":self
	})

	ComposerGD.AddScene("Settings","res://src/Settings/Settings.tscn",
	{
		"instant_load":true,
		"scene_parent":self
	})

	ComposerGD.AddScene("Credits","res://src/Credits/Credits.tscn",
	{
		"instant_load":true,
		"scene_parent":self
	})

func play_menu_theme() -> void:
	if not menu_theme.playing:
		menu_theme.play()

func stop_menu_theme() -> void:
	menu_theme.stop()
