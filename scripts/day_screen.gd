extends CanvasLayer

@onready var day: Label = $Day

func _ready() -> void:

	if Global.current_day == 1:
		day.text = "Monday"
		
		Global.spawn_position = Vector2(-350, -70)
		Global.on_bed = true
		Global.can_move = false
		
		await get_tree().create_timer(2.0).timeout
		ScreenTrans.change_scene("res://scenes/areas/bedroom_01.tscn", 3)


	if Global.current_day == 2:
		day.text = "Tuesday"
		
		Global.spawn_position = Vector2(-350, -70)
		Global.player_glow_radius = 1.6
		Global.lh_tv_on = true
		Global.kitchen_fridge_01_open = false
		Global.bedroom_door_lock = true
		Global.on_bed = true
		Global.can_move = false
		Global.front_door_lock = false
		
		Global.has_food = false
		Global.has_fed = false
		Global.has_house_key = false
		Global.has_money = false
		
		await get_tree().create_timer(2.0).timeout
		ScreenTrans.change_scene("res://scenes/areas/bedroom_01.tscn", 3)


	if Global.current_day == 3:
		day.text = "Wednesday"
		
		Global.spawn_position = Vector2(-350, -70)
		Global.player_glow_radius = 1.6
		Global.lh_tv_on = false
		Global.kitchen_fridge_01_open = false
		Global.bedroom_door_lock = true
		Global.on_bed = true
		Global.can_move = false
		
		Global.has_food = false
		Global.has_fed = false
		Global.has_house_key = false
		Global.has_money = false
		
		Global.day_2_trigger = false
		
		await get_tree().create_timer(2.0).timeout
		ScreenTrans.change_scene("res://scenes/areas/bedroom_01.tscn", 3)


	if Global.current_day == 4:
		day.text = "Demo End  |  Thank you for playing!"
		Global.reset()
		await get_tree().create_timer(2.0).timeout
		ScreenTrans.change_scene("res://scenes/screens/main_menu.tscn", 3)
