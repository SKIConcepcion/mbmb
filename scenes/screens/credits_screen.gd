extends Control

func _on_back_pressed() -> void:
	GlobalSfx.button_click.play()
	ScreenTrans.change_scene("res://scenes/screens/main_menu.tscn", 0)
