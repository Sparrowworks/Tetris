extends Node2D

@onready var music_volume: Label = %MusicVolume
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_volume: Label = %SfxVolume
@onready var sfx_slider: HSlider = %SfxSlider

func _ready() -> void:
	music_volume.text = "Music Volume: " + str(Global.music_volume)
	sfx_volume.text = "SFX Volume: " + str(Global.sfx_volume)

	music_slider.value = Global.music_volume
	sfx_slider.value = Global.sfx_volume

func _on_back_pressed() -> void:
	Global.main.cross_fade("Settings","MainMenu")

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	music_slider.release_focus()

func _on_music_slider_value_changed(value: float) -> void:
	Global.music_volume = value

	music_volume.text = "Music Volume: " + str(Global.music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(Global.music_volume/100))

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	sfx_slider.release_focus()

func _on_sfx_slider_value_changed(value: float) -> void:
	Global.sfx_volume = value

	sfx_volume.text = "SFX Volume: " + str(Global.sfx_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(Global.sfx_volume/100))
