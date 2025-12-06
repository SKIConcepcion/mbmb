extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var street_light_01: PointLight2D = $Items/street_light_01
@onready var street_light_02: PointLight2D = $Items/street_light_02
@onready var street_light_03: PointLight2D = $Items/street_light_03
@onready var street_light_04: PointLight2D = $Items/street_light_04
@onready var tree_01: AnimatedSprite2D = $Items/tree_01

@onready var night_ambiance: AudioStreamPlayer = $Sounds/NightAmbiance
@onready var light_01: AudioStreamPlayer2D = $Sounds/Light01
@onready var clockwork_sfx: AudioStreamPlayer2D = $Sounds/ClockworkSfx

@onready var herod: CharacterBody2D = $Herod

@onready var auto_dialogue_tues_05: Area2D = $Texts/AutoDialogueTues05
@onready var dialogue_tues_02: Area2D = $Texts/DialogueTues02
@onready var auto_dialogue_wed_02: Area2D = $Texts/AutoDialogueWed02

var tree_01_hop_timer: Timer
var is_tree_01_hopping: bool = false
var player_has_set_can_move: bool = false
var flicker_running := false
var ambiance_switched := false  # Prevents repeated switching



func _ready() -> void:
	if Global.current_day != 2:
		auto_dialogue_tues_05.queue_free()
		dialogue_tues_02.queue_free()

	if Global.current_day != 3:
		_switch_to_day2_mode()
		auto_dialogue_wed_02.queue_free()
	
	if !Global.day_3_trigger:
		clockwork_sfx.queue_free()
	
	# 🌲 Tree hop timer setup
	tree_01_hop_timer = Timer.new()
	tree_01_hop_timer.wait_time = 1.0
	tree_01_hop_timer.one_shot = false
	add_child(tree_01_hop_timer)
	tree_01_hop_timer.timeout.connect(func(): _on_hop_timeout("tree_01"))

	# 👤 Check if player supports movement locking
	if player and player.has_method("set_can_move"):
		player_has_set_can_move = true

	# 💡 Start flicker and handle Herod only if day_2_trigger is active
	if Global.day_2_trigger:
		_switch_to_day2_mode()
	else:
		if herod:
			herod.queue_free()  



func _process(_delta: float) -> void:
	var on_tree_01 := Global.on_tree_01

	# 👤 Player visibility + movement
	if player:
		var can_move := not (on_tree_01)
		player_sprite.visible = can_move

		if can_move:
			player_light.texture_scale = 1.0
		else:
			player_light.texture_scale = 0.7

		if player_has_set_can_move:
			player.set_can_move(can_move)
		elif "can_move" in player:
			player.can_move = can_move

	# 🧸 Tree hop logic
	if on_tree_01:
		if not is_tree_01_hopping:
			tree_01.frame = 1
			tree_01_hop_timer.start()
			is_tree_01_hopping = true
			GlobalSfx.box_crunch.play()
	else:
		tree_01.frame = 0
		if is_tree_01_hopping:
			tree_01_hop_timer.stop()
			is_tree_01_hopping = false
			GlobalSfx.bush.play()

	# 💀 Remove Herod once he leaves the area
	if herod and herod.is_inside_tree():
		if herod.global_position.x < -8500:
			herod.queue_free()
			herod = null
			flicker_running = false

	# 🎧 Switch ambiance once day_2_trigger activates (if it happens mid-scene)
	if Global.day_2_trigger and not ambiance_switched:
		_switch_to_day2_mode()



func _on_hop_timeout(target: String) -> void:
	if target == "tree_01" and Global.on_tree_01:
		tree_01.frame = 3 - tree_01.frame



# 💡 Constant flicker coroutine
func _start_street_light_01_flicker() -> void:
	await get_tree().process_frame
	while flicker_running:
		if street_light_01:
			# OFF
			street_light_01.energy = 0.0
			await get_tree().create_timer(randf_range(0.1, 0.25)).timeout

			# ON (with slight random dimming)
			street_light_01.energy = randf_range(0.4, 0.7)
			await get_tree().create_timer(randf_range(0.1, 0.4)).timeout



# 🎵 Switch ambiance + start flicker
func _switch_to_day2_mode() -> void:
	ambiance_switched = true

	# Stop night ambiance
	if night_ambiance and night_ambiance.playing:
		night_ambiance.stop()

	# Start light buzz / flicker sound
	if light_01 and not light_01.playing:
		light_01.play()

	# Start flicker effect
	if street_light_01 and not flicker_running:
		flicker_running = true
		_start_street_light_01_flicker()
