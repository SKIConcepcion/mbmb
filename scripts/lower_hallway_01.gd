extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var large_plant_01: AnimatedSprite2D = $Items/large_plant_01
@onready var large_plant_02: AnimatedSprite2D = $Items/large_plant_02

@onready var front_door_01: AnimatedSprite2D = $Items/front_door_01
@onready var lower_hallway_door_01a: Area2D = $Triggers/LowerHallwayDoor01A

@onready var tv_static: TextureRect = $Items/TvStatic
@onready var static_sound: AudioStreamPlayer2D = $Sounds/StaticSound
@onready var tv_light: PointLight2D = $Items/tv_light

@onready var elesi: Sprite2D = $Items/elesi
@onready var fish_01: Sprite2D = $Items/fish_01
@onready var fish_02: Sprite2D = $Items/fish_02

@onready var visage: CharacterBody2D = $Visage
@onready var wallet_01: Area2D = $Items/Wallet01
@onready var house_key: Area2D = $Items/HouseKey

@onready var auto_dialogue_mon_03: Area2D = $Texts/AutoDialogueMon03
@onready var auto_dialogue_tues_07: Area2D = $Texts/AutoDialogueTues07
@onready var auto_dialogue_wed_03: Area2D = $Texts/AutoDialogueWed03
@onready var lower_hallway_pill: Area2D = $Items/LowerHallwayPill


var large_plant_01_hop_timer: Timer
var large_plant_02_hop_timer: Timer

var is_large_plant_01_hopping: bool = false
var is_large_plant_02_hopping: bool = false
var player_has_set_can_move: bool = false

const ELESI_SPIN_SPEED := 5.0

# Store fish original positions and bounds
var fish_01_origin: Vector2
var fish_02_origin: Vector2

const FISH_MOVE_RADIUS := 20.0  # how far fish can wander
const FISH_MIN_SPEED := 1.0     # sec per move
const FISH_MAX_SPEED := 2.5


func _ready() -> void:
	if Global.lh_pill_taken:
		lower_hallway_pill.queue_free()

	if Global.has_house_key:
		house_key.queue_free()
		
	if Global.has_money:
		wallet_01.queue_free()
	
	if !Global.day_2_trigger:
		auto_dialogue_tues_07.queue_free()
	
	if Global.current_day != 1:
		auto_dialogue_mon_03.queue_free()
	
	if Global.current_day != 2:
		auto_dialogue_tues_07.queue_free()
		wallet_01.queue_free()
		
	if Global.current_day != 3:
		auto_dialogue_wed_03.queue_free()
		house_key.queue_free()
		
	if Global.current_day != 4:
		visage.queue_free()
	
	# 🧸 janitorial_cabinet hop timer
	large_plant_01_hop_timer = Timer.new()
	large_plant_01_hop_timer.wait_time = 1.0
	large_plant_01_hop_timer.one_shot = false
	add_child(large_plant_01_hop_timer)
	large_plant_01_hop_timer.timeout.connect(func(): _on_hop_timeout("large_plant_01"))

	large_plant_02_hop_timer = Timer.new()
	large_plant_02_hop_timer.wait_time = 1.0
	large_plant_02_hop_timer.one_shot = false
	add_child(large_plant_02_hop_timer)
	large_plant_02_hop_timer.timeout.connect(func(): _on_hop_timeout("large_plant_02"))

	# Cache if player supports set_can_move()
	if player and player.has_method("set_can_move"):
		player_has_set_can_move = true

	# Store fish original positions
	fish_01_origin = fish_01.position
	fish_02_origin = fish_02.position

	# Start random swim
	_fish_swim_random(fish_01, fish_01_origin)
	_fish_swim_random(fish_02, fish_02_origin)


func _process(delta: float) -> void:
	elesi.rotation -= ELESI_SPIN_SPEED * delta

	var on_large_plant_01 := Global.on_large_plant_01
	var on_large_plant_02 := Global.on_large_plant_02

	# 👤 Player visibility + movement
	if player:
		var can_move := not (on_large_plant_01 or on_large_plant_02)

		player_sprite.visible = can_move
		player_light.texture_scale = 1.0 if can_move else 0.7

		if player_has_set_can_move:
			player.set_can_move(can_move)
		elif "can_move" in player:
			player.can_move = can_move

	if on_large_plant_01:
		if not is_large_plant_01_hopping:
			large_plant_01.frame = 1
			large_plant_01_hop_timer.start()
			is_large_plant_01_hopping = true
			_shake_large_plant_01()
			GlobalSfx.bush.play()
	else:
		large_plant_01.frame = 0
		if is_large_plant_01_hopping:
			large_plant_01_hop_timer.stop()
			is_large_plant_01_hopping = false
			GlobalSfx.bush.play()

	if on_large_plant_02:
		if not is_large_plant_02_hopping:
			large_plant_02.frame = 1
			large_plant_02_hop_timer.start()
			is_large_plant_02_hopping = true
			_shake_large_plant_02()
			GlobalSfx.bush.play()
	else:
		large_plant_02.frame = 0
		if is_large_plant_02_hopping:
			large_plant_02_hop_timer.stop()
			is_large_plant_02_hopping = false
			GlobalSfx.bush.play()
			
	if Global.front_door_lock:
		front_door_01.frame = 0
		lower_hallway_door_01a.set_deferred("monitoring", false) 
		lower_hallway_door_01a.set_deferred("monitorable", false) 
	else:
		front_door_01.frame = 1
		lower_hallway_door_01a.set_deferred("monitoring", true) 
		lower_hallway_door_01a.set_deferred("monitorable", true) 
		
		
	if Global.lh_tv_on:
		tv_static.visible = true
		tv_light.visible = true
		if not static_sound.playing:
			static_sound.play()
	else:
		tv_static.visible = false
		tv_light.visible = false
		if static_sound.playing:
			static_sound.stop()


func _on_hop_timeout(target: String) -> void:
	if target == "large_plant_01" and Global.on_large_plant_01:
		large_plant_01.frame = 3 - large_plant_01.frame
	elif target == "large_plant_02" and Global.on_large_plant_02:
		large_plant_02.frame = 3 - large_plant_02.frame


func _shake_large_plant_01() -> void:
	var original_pos := large_plant_01.position
	var tween := create_tween()
	for i in range(3):
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5))
		tween.tween_property(large_plant_01, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(large_plant_01, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _shake_large_plant_02() -> void:
	var original_pos := large_plant_02.position
	var tween := create_tween()
	for i in range(3):
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5))
		tween.tween_property(large_plant_02, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(large_plant_02, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


# 🐟 Fish random swimming
func _fish_swim_random(fish: Sprite2D, origin: Vector2) -> void:
	var target_offset = Vector2(randf_range(-FISH_MOVE_RADIUS, FISH_MOVE_RADIUS),
								randf_range(-FISH_MOVE_RADIUS, FISH_MOVE_RADIUS))
	var target_pos = origin + target_offset

	# Flip fish if direction changes
	if target_pos.x < fish.position.x:
		fish.flip_h = true
	else:
		fish.flip_h = false

	var duration = randf_range(FISH_MIN_SPEED, FISH_MAX_SPEED)

	var tween := create_tween()
	tween.tween_property(fish, "position", target_pos, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# After finishing, call again for endless wandering
	tween.finished.connect(func():
		# tiny pause before next move
		await get_tree().create_timer(randf_range(0.2, 0.8)).timeout
		_fish_swim_random(fish, origin))
