extends Node2D

func _on_back_pressed() -> void:
	Global.main.cross_fade("Credits","MainMenu")
