extends Control

func _ready() -> void:
	if not GlobalSfx.music_box.playing:
		GlobalSfx.fade_in_music_box()

func _on_start_pressed() -> void:
	GlobalSfx.button_click.play()
	ScreenTrans.change_scene("res://scenes/screens/intro_cutscene.tscn", 2)

func _on_credits_pressed() -> void:
	GlobalSfx.button_click.play()
	ScreenTrans.change_scene("res://scenes/screens/credits_screen.tscn", 0)
