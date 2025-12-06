extends CharacterBody2D

const TELEPORT_DISTANCE := 100.0   # How far to teleport each time
const MIN_INTERVAL := 0.5        # Minimum teleport interval
const MAX_INTERVAL := 1.0       # Maximum teleport interval

var direction := -1                 # 1 = right, -1 = left
var player_in_zone: Node = null
var flicker_tween: Tween = null
var teleport_timer: Timer


func _ready() -> void:
	# Create and start the teleport timer
	teleport_timer = Timer.new()
	add_child(teleport_timer)
	teleport_timer.timeout.connect(_teleport)
	_set_random_interval()
	teleport_timer.start()



# --- TELEPORTATION LOGIC ---

func _teleport() -> void:
	# Randomize next teleport interval each time
	_set_random_interval()

	# Predict next position
	var next_pos = global_position + Vector2(TELEPORT_DISTANCE * direction, 0)

	# Check if next teleport would hit a wall
	if test_move(transform, Vector2(TELEPORT_DISTANCE * direction, 0)):
		# Flip direction if blocked
		direction *= -1
		next_pos = global_position + Vector2(TELEPORT_DISTANCE * direction, 0)

	# Teleport to the next position
	global_position = next_pos


func _set_random_interval() -> void:
	var random_time = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	teleport_timer.wait_time = random_time
	teleport_timer.start()


# --- PLAYER TRACKING ---

func _on_tracker_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = body
		var pd = player_in_zone.get_node_or_null("CanvasLayer/PlayerDarkness")
		if pd:
			pd.visible = true
			_start_darkness_flicker(pd)


func _on_tracker_zone_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		_stop_darkness_flicker(body)
		player_in_zone = null


# --- DARKNESS EFFECTS ---

func _start_darkness_flicker(player_darkness: ColorRect) -> void:
	if flicker_tween and flicker_tween.is_running():
		flicker_tween.kill()
	flicker_tween = create_tween().set_loops()
	flicker_tween.tween_property(player_darkness, "modulate:a", 0.7, 0.5)
	flicker_tween.tween_property(player_darkness, "modulate:a", 0.3, 0.5)


func _stop_darkness_flicker(player: Node2D) -> void:
	if flicker_tween and flicker_tween.is_running():
		flicker_tween.kill()
	var pd = player.get_node_or_null("CanvasLayer/PlayerDarkness")
	if pd:
		var fade := create_tween()
		fade.tween_property(pd, "modulate:a", 0.0, 0.3)
		await fade.finished
		pd.visible = false


# --- KILLZONE DETECTION ---

func _on_killzone_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not Global.hidden:
		Global.game_over()
