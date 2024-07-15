extends Node2D

@onready var menu_theme: AudioStreamPlayer = $MenuTheme
@onready var color_rect: ColorRect = $CanvasLayer/Control/ColorRect
@onready var button_click: AudioStreamPlayer = $ButtonClick

var is_changing_scene: bool = false

func _ready() -> void:
	randomize()

	Global.main = self

	ComposerGD.AddScene("Game","res://src/Game/Game.tscn",
	{
		"instant_load":true,
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

	cross_launch()

func cross_launch() -> void:
	color_rect.modulate = Color(1.0,1.0,1.0,1.0)

	ComposerGD.AddScene("MainMenu","res://src/MainMenu/MainMenu.tscn",
	{
		"instant_load":true,
		"instant_create":true,
		"scene_parent":self
	})

	await Composer.SceneCreated

	var cross_tween: Tween = get_tree().create_tween()
	cross_tween.tween_property(color_rect,"modulate:a",0.0,1.0)

func cross_fade(old_scene: String, new_scene: String) -> void:
	if is_changing_scene: return

	is_changing_scene = true

	button_click.play()

	var cross_tween: Tween = get_tree().create_tween()
	cross_tween.tween_property(color_rect,"modulate:a",1.0,1.0)
	cross_tween.tween_callback(
		func() -> void:
			ComposerGD.ReplaceScene(old_scene, new_scene, self)
	)
	cross_tween.tween_property(color_rect,"modulate:a",0.0,1.0)

	await cross_tween.finished

	is_changing_scene = false

func play_menu_theme() -> void:
	if not menu_theme.playing:
		menu_theme.play()

func stop_menu_theme() -> void:
	menu_theme.stop()
