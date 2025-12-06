extends Node

var spawn_position := Vector2(-350, -70)
var current_day: int = 1

var hidden: bool = false
var can_move: bool = true

var player_glow_radius: float = 1.6
var player_pill_count: int = 3
var player_inventory: Array = []
var triggered_dialogues := {}


### ITEMS FLAGS ###
var has_food: bool = false
var has_fed: bool = false

var has_house_key: bool = false
var has_money: bool = false


### TOGGLES FLAGS ###
var on_bed: bool = true
var on_toybox: bool = false
var on_janitorial_cabinet: bool = false
var on_large_plant_01: bool = false
var on_large_plant_02: bool = false
var on_large_plant_03: bool = false
var on_large_plant_04: bool = false
var on_tree_01: bool = false

var bedroom_door_lock: bool = true
var bathroom_door_lock: bool = false
var front_door_lock: bool = true

var uh_lamp_light: bool = false

var bathroom_faucet_01_on: bool = false
var bathroom_faucet_02_on: bool = false
var kitchen_faucet_on: bool = false

var lh_tv_on: bool = false
var kitchen_fridge_01_open: bool = false


### EVENT FLAGS ###
var day_2_trigger: bool = false
var day_3_trigger: bool = false
var day_4_trigger: bool = false

var wallet_loc_known: bool = false
var conv_pill_taken: bool = false
var lh_pill_taken: bool = false






func game_over():
	Global.spawn_position = Vector2(-350, -70)
	ScreenTrans.death_scene("res://scenes/areas/mental_room_01.tscn")

func reset() -> void:
	spawn_position = Vector2(-350, -70)
	current_day = 1

	hidden = false
	can_move = true

	player_glow_radius = 1.6
	player_pill_count = 3
	player_inventory.clear()
	triggered_dialogues.clear()

	# ITEMS FLAGS
	has_food = false
	has_fed = false
	has_house_key = false
	has_money = false

	# TOGGLES FLAGS
	on_bed = true
	on_toybox = false
	on_janitorial_cabinet = false
	on_large_plant_01 = false
	on_large_plant_02 = false
	on_large_plant_03 = false
	on_large_plant_04 = false
	on_tree_01 = false

	bedroom_door_lock = true
	bathroom_door_lock = false
	front_door_lock = true

	uh_lamp_light = false
	bathroom_faucet_01_on = false
	bathroom_faucet_02_on = false
	kitchen_faucet_on = false

	lh_tv_on = false
	kitchen_fridge_01_open = false

	# EVENT FLAGS
	day_2_trigger = false
	day_3_trigger = false
	day_4_trigger = false
	wallet_loc_known = false
	conv_pill_taken = false
	lh_pill_taken = false
