extends Node2D

func _on_back_pressed() -> void:
	ComposerGD.ReplaceScene("Credits","MainMenu",Global.main)
