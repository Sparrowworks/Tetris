extends Node2D

@onready var loading_transition: String = "res://src/FadeScreen/FadeScreen.tscn"
@onready var menu_theme: AudioStreamPlayer = $MenuTheme
@onready var button_click: AudioStreamPlayer = $ButtonClick

var is_changing_scene: bool = false

func _ready() -> void:
	Composer.root = self
	randomize()

	Global.main = self

	Composer.load_scene("res://src/MainMenu/MainMenu.tscn")

func go_to(scene: String) -> void:
	var transition: Node = Composer.setup_load_screen(loading_transition)

	if transition:
		await transition.finished_fade_in
		Composer.load_scene(scene)

func play_menu_theme() -> void:
	if not menu_theme.playing:
		menu_theme.play()

func stop_menu_theme() -> void:
	menu_theme.stop()
