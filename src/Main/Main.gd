extends Node2D

func _ready() -> void:
	ComposerGD.AddScene("MainMenu","res://src/MainMenu/MainMenu.tscn",
	{
		"instant_load":true,
		"instant_create":true,
		"scene_parent":self
	})
