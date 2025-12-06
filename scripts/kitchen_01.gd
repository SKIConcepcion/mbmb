extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var large_plant_04: AnimatedSprite2D = $Items/large_plant_04
@onready var elesi: Sprite2D = $Items/elesi

@onready var water_01: Sprite2D = $Items/water_01
@onready var water_01_sfx: AudioStreamPlayer2D = $Sounds/Water01
@onready var fridge: AnimatedSprite2D = $Items/fridge

@onready var food_01: Area2D = $Triggers/Food01
@onready var house_key: Area2D = $Triggers/HouseKey

@onready var dialogue_mon_04: Area2D = $Texts/DialogueMon04
@onready var auto_dialogue_mon_04: Area2D = $Texts/AutoDialogueMon04
@onready var auto_dialogue_tues_04: Area2D = $Texts/AutoDialogueTues04
@onready var dialogue_tues_01: Area2D = $Texts/DialogueTues01
@onready var dialogue_wed_01: Area2D = $Texts/DialogueWed01


var player_has_set_can_move: bool = false

var large_plant_04_hop_timer: Timer
var is_large_plant_04_hopping: bool = false

const ELESI_SPIN_SPEED := 5.0



func _ready() -> void:
	
	if Global.has_house_key:
		house_key.queue_free()
		
	if Global.has_food:
		food_01.queue_free()
	
	if Global.current_day != 1:
		food_01.queue_free()
		dialogue_mon_04.queue_free()
		auto_dialogue_mon_04.queue_free()
	
	if Global.current_day != 2:
		house_key.queue_free()
		auto_dialogue_tues_04.queue_free()
		dialogue_tues_01.queue_free()
		
	if Global.current_day != 3:
		dialogue_wed_01.queue_free()

	# 🧸 janitorial_cabinet hop timer
	large_plant_04_hop_timer = Timer.new()
	large_plant_04_hop_timer.wait_time = 1.0
	large_plant_04_hop_timer.one_shot = false
	add_child(large_plant_04_hop_timer)
	large_plant_04_hop_timer.timeout.connect(func(): _on_hop_timeout("large_plant_04"))

	# Cache if player supports set_can_move()
	if player and player.has_method("set_can_move"):
		player_has_set_can_move = true



func _process(delta: float) -> void:
	elesi.rotation -= ELESI_SPIN_SPEED * delta

	var on_large_plant_04 := Global.on_large_plant_04

	# 👤 Player visibility + movement
	if player:
		var can_move := not on_large_plant_04

		player_sprite.visible = can_move
		player_light.texture_scale = 1.0 if can_move else 0.7

		if player_has_set_can_move:
			player.set_can_move(can_move)
		elif "can_move" in player:
			player.can_move = can_move

	if on_large_plant_04:
		if not is_large_plant_04_hopping:
			large_plant_04.frame = 1
			large_plant_04_hop_timer.start()
			is_large_plant_04_hopping = true
			_shake_large_plant_01()
			GlobalSfx.bush.play()
	else:
		large_plant_04.frame = 0
		if is_large_plant_04_hopping:
			large_plant_04_hop_timer.stop()
			is_large_plant_04_hopping = false
			GlobalSfx.bush.play()
			
	
	water_01.visible = Global.kitchen_faucet_on
	if Global.kitchen_faucet_on:
		if not water_01_sfx.playing:
			water_01_sfx.play()
	else:
		if water_01_sfx.playing:
			water_01_sfx.stop()
			
	if Global.kitchen_fridge_01_open:
		fridge.frame = 1
		if food_01:
			food_01.visible = true
		if dialogue_tues_01:
			dialogue_tues_01.visible = true
		if dialogue_wed_01:
			dialogue_wed_01.visible = true
	else:
		fridge.frame = 0
		if food_01:
			food_01.visible = false
		if dialogue_tues_01:
			dialogue_tues_01.visible = false
		if dialogue_wed_01:
			dialogue_wed_01.visible = false

func _on_hop_timeout(target: String) -> void:
	if target == "large_plant_04" and Global.on_large_plant_04:
		large_plant_04.frame = 3 - large_plant_04.frame


func _shake_large_plant_01() -> void:
	var original_pos := large_plant_04.position
	var tween := create_tween()
	for i in range(3):
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5))
		tween.tween_property(large_plant_04, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(large_plant_04, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
