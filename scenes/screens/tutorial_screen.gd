extends CanvasLayer

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var next_button: TextureButton = $NextButton

func _ready() -> void:
	GlobalSfx.paper.play()
	sprite_2d.modulate.a = 0.0
	_fade_in()

func _on_next_button_pressed() -> void:
	GlobalSfx.button_click.play()
	GlobalSfx.fade_out_music_box(3.0)
	_fade_out_to_scene("res://scenes/screens/day_screen.tscn")


# --- FADE FUNCTIONS ---

func _fade_in(duration: float = 1.5) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _fade_out_to_scene(scene_path: String, duration: float = 1.5) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(next_button, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)	
	tween.tween_callback(func ():
		ScreenTrans.change_scene(scene_path, 0)
	)
