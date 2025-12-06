extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var janitorial_cabinet: AnimatedSprite2D = $Items/janitorial_cabinet
@onready var large_plant_03: AnimatedSprite2D = $Items/large_plant_03

@onready var uh_lamp_light: PointLight2D = $Items/uh_lamp_light
@onready var tv_static: AudioStreamPlayer2D = $Sounds/TvStatic

@onready var visage: CharacterBody2D = $Visage

@onready var dialogue_mon_01: Area2D = $Texts/DialogueMon01
@onready var dialogue_mon_02: Area2D = $Texts/DialogueMon02
@onready var auto_dialogue_tues_02: Area2D = $Texts/AutoDialogueTues02
@onready var auto_dialogue_tues_03: Area2D = $Texts/AutoDialogueTues03
@onready var auto_dialogue_wed_01: Area2D = $Texts/AutoDialogueWed01
@onready var uh_fam_pic: AnimatedSprite2D = $Items/uh_fam_pic



var janitorial_cabinet_hop_timer: Timer
var large_plant_hop_timer: Timer

var is_janitorial_cabinet_hopping: bool = false
var is_large_plant_hopping: bool = false
var player_has_set_can_move: bool = false


func _ready() -> void:
	
	if Global.current_day != 1:
		dialogue_mon_01.queue_free()
		dialogue_mon_02.queue_free()
	
	if Global.current_day != 2:
		auto_dialogue_tues_02.queue_free()
		auto_dialogue_tues_03.queue_free()
	
	if Global.current_day != 3:
		auto_dialogue_wed_01.queue_free()
	
	if !Global.day_3_trigger:
		visage.queue_free()
		
	if !Global.lh_tv_on:
		tv_static.queue_free()
	
	# 🧸 janitorial_cabinet hop timer
	janitorial_cabinet_hop_timer = Timer.new()
	janitorial_cabinet_hop_timer.wait_time = 1.0
	janitorial_cabinet_hop_timer.one_shot = false
	add_child(janitorial_cabinet_hop_timer)
	janitorial_cabinet_hop_timer.timeout.connect(func(): _on_hop_timeout("janitorial_cabinet"))


	# 🧸 janitorial_cabinet hop timer
	large_plant_hop_timer = Timer.new()
	large_plant_hop_timer.wait_time = 1.0
	large_plant_hop_timer.one_shot = false
	add_child(large_plant_hop_timer)
	large_plant_hop_timer.timeout.connect(func(): _on_hop_timeout("large_plant_03"))


	# Cache if player supports set_can_move()
	if player and player.has_method("set_can_move"):
		player_has_set_can_move = true


func _process(_delta: float) -> void:

	var on_janitorial_cabinet := Global.on_janitorial_cabinet
	var on_large_plant_03 := Global.on_large_plant_03
	var uh_lamp_state := Global.uh_lamp_light

	# 👤 Player visibility + movement
	if player:
		var can_move := not (on_janitorial_cabinet or on_large_plant_03)

		# Sprite follows visibility
		player_sprite.visible = can_move

		# Light size depends on movement state
		if can_move:
			player_light.texture_scale = 1.0   # normal size
		else:
			player_light.texture_scale = 0.7   # smaller when stuck

		# Handle movement
		if player_has_set_can_move:
			player.set_can_move(can_move)
		elif "can_move" in player:
			player.can_move = can_move

	if uh_lamp_light:
		uh_lamp_light.visible = uh_lamp_state 
		uh_lamp_light.enabled = uh_lamp_state

	# 🧸 janitorial_cabinet logic
	if on_janitorial_cabinet:
		if not is_janitorial_cabinet_hopping:
			janitorial_cabinet.frame = 1
			janitorial_cabinet_hop_timer.start()
			is_janitorial_cabinet_hopping = true

			# 🔄 Trigger janitorial_cabinet shake when entering
			_shake_janitorial_cabinet()
			GlobalSfx.cabinet.play()
	else:
		janitorial_cabinet.frame = 0
		if is_janitorial_cabinet_hopping:
			janitorial_cabinet_hop_timer.stop()
			is_janitorial_cabinet_hopping = false
			GlobalSfx.cabinet.play()

	if on_large_plant_03:
		if not is_large_plant_hopping:
			large_plant_03.frame = 1
			large_plant_hop_timer.start()
			is_large_plant_hopping = true

			# 🔄 Trigger janitorial_cabinet shake when entering
			_shake_large_plant_03()
			GlobalSfx.bush.play()
	else:
		large_plant_03.frame = 0
		if is_large_plant_hopping:
			large_plant_hop_timer.stop()
			is_large_plant_hopping = false
			GlobalSfx.bush.play()


func _on_hop_timeout(target: String) -> void:
	if target == "janitorial_cabinet" and Global.on_janitorial_cabinet:
		janitorial_cabinet.frame = 3 - janitorial_cabinet.frame
	elif target == "large_plant_03" and Global.on_large_plant_03:
		large_plant_03.frame = 3 - large_plant_03.frame

	
func _shake_janitorial_cabinet() -> void:
	var original_pos := janitorial_cabinet.position
	var tween := create_tween()

	# Shake for ~1 second total (5 little shakes)
	for i in range(5):
		var offset := Vector2(randf_range(-1.2, 1.2), randf_range(-0.5, 0.5))
		tween.tween_property(janitorial_cabinet, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(janitorial_cabinet, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _shake_large_plant_03() -> void:
	var original_pos := large_plant_03.position
	var tween := create_tween()

	# Shake for ~1 second total (5 little shakes)
	for i in range(3):
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5))
		tween.tween_property(large_plant_03, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(large_plant_03, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
