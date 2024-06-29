extends Node2D

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
