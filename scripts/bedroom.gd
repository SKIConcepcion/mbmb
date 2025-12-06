extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var bed: AnimatedSprite2D = $Items/bed
@onready var clouds: Sprite2D = $Items/clouds
@onready var elesi: Sprite2D = $Items/elesi
@onready var light_01: PointLight2D = $Items/light_01
@onready var cabinet: AnimatedSprite2D = $Items/cabinet
@onready var door: AnimatedSprite2D = $Items/bedroom_door
@onready var toybox: AnimatedSprite2D = $Items/toybox

@onready var cabinet_shake: AudioStreamPlayer2D = $Sounds/CabinetShake
@onready var bedroom_door_01: Area2D = $Triggers/BedroomDoor01

@onready var darkness: CanvasModulate = $Darkness
@onready var herod: AnimatedSprite2D = $Herod

@onready var feed: Area2D = $Triggers/Feed

@onready var auto_dialogue_mon_01: Area2D = $Texts/AutoDialogueMon01
@onready var auto_dialogue_mon_02: Area2D = $Texts/AutoDialogueMon02
@onready var auto_dialogue_tues_01: Area2D = $Texts/AutoDialogueTues01

@onready var note_sprite: AnimatedSprite2D = $NoteCanvas/NoteSprite


var player_entered: bool = false
var trigger_note: bool = false

# 🕒 Timers
var bed_hop_timer: Timer
var toybox_hop_timer: Timer
var cabinet_timer: Timer

# 🔄 State flags
var is_bed_hopping: bool = false
var is_toybox_hopping: bool = false
var player_has_set_can_move: bool = false

# ☁️ Cloud movement settings
const CLOUD_SPEED := 25.0       # pixels per second
const CLOUD_LEFT_LIMIT := -550  # x-position before snapping back
const CLOUD_START_X := -100     # starting x-position (off-screen right)

# 🔄 Elesi spin settings
const ELESI_SPIN_SPEED := 5.0   # radians per second (≈115°/sec)

var herod_moving: bool = false
const HEROD_SPEED := 12.0

func _ready() -> void:
	
	note_sprite.frame = Global.current_day - 1

	if Global.current_day != 1:
		auto_dialogue_mon_01.queue_free()
		auto_dialogue_mon_02.queue_free()

	if Global.current_day != 2:
		auto_dialogue_tues_01.queue_free()

	if !Global.day_3_trigger:
		herod.queue_free()

	bed_hop_timer = Timer.new()
	bed_hop_timer.wait_time = 1.5
	bed_hop_timer.one_shot = false
	add_child(bed_hop_timer)
	bed_hop_timer.timeout.connect(func(): _on_hop_timeout("bed"))

	# 🧸 Toybox hop timer
	toybox_hop_timer = Timer.new()
	toybox_hop_timer.wait_time = 1.0
	toybox_hop_timer.one_shot = false
	add_child(toybox_hop_timer)
	toybox_hop_timer.timeout.connect(func(): _on_hop_timeout("toybox"))

	# 🚪 Cabinet shake timer
	cabinet_timer = Timer.new()
	cabinet_timer.wait_time = 3.0
	cabinet_timer.one_shot = true
	add_child(cabinet_timer)
	cabinet_timer.timeout.connect(_on_cabinet_shake)
	cabinet_timer.start()

	# Cache if player supports set_can_move()
	if player and player.has_method("set_can_move"):
		player_has_set_can_move = true

	# 💡 Optimize light
	light_01.shadow_enabled = false
	light_01.blend_mode = Light2D.BLEND_MODE_ADD


func _process(delta: float) -> void:
	var on_bed := Global.on_bed
	var on_toybox := Global.on_toybox

	# 👤 Player visibility + movement
	if player:
		var can_move := not (on_bed or on_toybox)

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

	if Global.day_3_trigger:
		herod_moving = true

	if herod_moving:
		herod.position.y += HEROD_SPEED * delta


	# 🛏️ Bed logic
	if on_bed:
		player_light.visible = false
		if not is_bed_hopping:
			bed.frame = 1
			bed_hop_timer.start()
			is_bed_hopping = true
			GlobalSfx.blanket.play()

	else:
		player_light.visible = true
		bed.frame = 0
		if is_bed_hopping:
			bed_hop_timer.stop()
			is_bed_hopping = false
			GlobalSfx.blanket.play()

	# 🧸 Toybox logic
	if on_toybox:
		if not is_toybox_hopping:
			toybox.frame = 1
			toybox_hop_timer.start()
			is_toybox_hopping = true

			# 🔄 Trigger toybox shake when entering
			_shake_toybox()
			GlobalSfx.box_crunch.play()
	else:
		toybox.frame = 0
		if is_toybox_hopping:
			toybox_hop_timer.stop()
			is_toybox_hopping = false
			GlobalSfx.box_crunch.play()


	# ☁️ Move clouds
	var cloud_x := clouds.position.x - CLOUD_SPEED * delta
	if cloud_x <= CLOUD_LEFT_LIMIT:
		cloud_x = CLOUD_START_X
	clouds.position.x = cloud_x

	# 🔄 Spin elesi
	elesi.rotation -= ELESI_SPIN_SPEED * delta

	if Global.bedroom_door_lock:
		door.frame = 1
		bedroom_door_01.set_deferred("monitoring", false) 
		bedroom_door_01.set_deferred("monitorable", false) 
	else:
		door.frame = 0
		bedroom_door_01.set_deferred("monitoring", true) 
		bedroom_door_01.set_deferred("monitorable", true) 


	if player_entered and Input.is_action_just_pressed("interact"):
		if Global.has_food:
			GlobalSfx.pickup.play()
			Global.current_day += 1
			player.remove_all_items()
			ScreenTrans.change_scene("res://scenes/screens/day_screen.tscn", 2)
		else:
			player.dialogue_text = "I must feed this with baby formula"
			GlobalSfx.hm.play()
			player.update_dialogue_label()

	# 📜 Note system
	if trigger_note and Input.is_action_just_pressed("interact"):
		note_sprite.visible = not note_sprite.visible




func _on_hop_timeout(target: String) -> void:
	if target == "bed" and Global.on_bed:
		bed.frame = 3 - bed.frame
	elif target == "toybox" and Global.on_toybox:
		toybox.frame = 3 - toybox.frame


func _on_cabinet_shake() -> void:
	var original_pos := cabinet.position
	var tween := create_tween()

	# Repeat ~5 shakes (~1s total)
	for i in range(5):
		var offset := Vector2(randf_range(-1.5, 1.5), randf_range(-0.5, 0.5))
		tween.tween_property(cabinet, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(cabinet, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		cabinet_shake.play()

	# After shaking, schedule next random shake
	tween.finished.connect(func ():
		cabinet_timer.wait_time = randf_range(5.0, 10.0)
		cabinet_timer.start()
	)
	
func _shake_toybox() -> void:
	var original_pos := toybox.position
	var tween := create_tween()

	# Shake for ~1 second total (5 little shakes)
	for i in range(3):
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5))
		tween.tween_property(toybox, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(toybox, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			


func _on_feed_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_feed_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false


func _on_note_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		trigger_note = true


func _on_note_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		trigger_note = false
		note_sprite.visible = false
