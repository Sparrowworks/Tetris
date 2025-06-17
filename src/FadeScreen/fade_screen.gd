extends CanvasLayer

signal finished_fade_in

@onready var fade_rect: ColorRect = %FadeRect

var fade_tween: Tween


func _ready() -> void:
	fade_in()
	Composer.finished_loading.connect(on_finished_loading)


func fade_in() -> void:
	fade_rect.color = Color(0, 0, 0, 0)

	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 0.75)
	fade_tween.tween_callback(
		func() -> void:
			fade_tween.kill()
			finished_fade_in.emit()
	)


func fade_out() -> void:
	fade_rect.color = Color(0, 0, 0, 1)

	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 0.0, 0.75)
	fade_tween.tween_callback(
		func() -> void:
			fade_tween.kill()
			Composer.clear_load_screen()
	)


func on_finished_loading(scene: Node) -> void:
	fade_out()
