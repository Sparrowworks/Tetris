extends Node2D

func _ready() -> void:
	Global.main = self

	ComposerGD.AddScene("Game","res://src/Game/Game.tscn",
	{
		"instant_load":true
	})

	ComposerGD.AddScene("MainMenu","res://src/MainMenu/MainMenu.tscn",
	{
		"instant_load":true,
		"instant_create":true,
		"scene_parent":self
	})
