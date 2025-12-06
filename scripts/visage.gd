extends CharacterBody2D

@onready var left: ColorRect = $Left   # Tragedy face
@onready var right: ColorRect = $Right  # Comedy face

@onready var circus_sfx: AudioStreamPlayer2D = $CircusSfx

var player_in_zone: Node = null
var tragedy_active: bool = true
var draining_light: bool = false

func _ready() -> void:
	update_faces()


func _physics_process(delta: float) -> void:
	# Detect when player flicks their light
	if Input.is_action_just_pressed("light"):
		toggle_face()

	# If comedy face is active and player is in zone → drain light
	if not tragedy_active and player_in_zone and draining_light:
		drain_player_light(delta)


func _on_tracker_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = body
		if not tragedy_active:
			draining_light = true


func _on_tracker_zone_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		player_in_zone = null
		draining_light = false


func _on_killzone_body_entered(body: Node2D) -> void:
	if body.name == "Player" and tragedy_active:
		Global.game_over()


func toggle_face() -> void:
	tragedy_active = not tragedy_active
	update_faces()

	# If switched to Tragedy → stop draining
	if tragedy_active:
		draining_light = false
	else:
		if player_in_zone:
			draining_light = true


func update_faces() -> void:
	if tragedy_active:
		left.color = Color.RED
		right.color = Color.BLACK
		circus_sfx.pitch_scale = 0.8  
	else:
		left.color = Color.BLACK
		right.color = Color.RED
		circus_sfx.pitch_scale = 1.5  

	# Restart sound if not playing
	if not circus_sfx.playing:
		circus_sfx.play()



func drain_player_light(delta: float) -> void:
	if not player_in_zone:
		return

	var player = player_in_zone

	# === ENERGY DRAIN ===
	if player.glowstick.energy > player.MIN_ENERGY:
		player.glowstick.energy = max(player.MIN_ENERGY, player.glowstick.energy - 0.2 * delta)

	# === RADIUS DRAIN ===
	var new_radius = clamp(player.glowstick.scale.x - (0.1 * delta), player.MIN_RADIUS, player.MAX_RADIUS)
	player.glowstick.scale = Vector2(new_radius, new_radius)
	Global.player_glow_radius = new_radius 
