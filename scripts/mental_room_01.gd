extends Node2D

@onready var music_box_sfx: AudioStreamPlayer2D = $Sounds/MusicBoxSfx
@onready var player: CharacterBody2D = $Player

var player_entered = false

func _ready() -> void:
	player.glowstick.energy = 0.0
	
	# Make sure the sound does not loop
	if music_box_sfx.stream:
		music_box_sfx.stream.loop = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		music_box_sfx.play()
		_reset_game_after_delay()  # trigger reset sequence

func _on_music_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_music_box_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false


# --- Custom function for reset and scene change ---
func _reset_game_after_delay() -> void:
	# Run asynchronously
	await get_tree().create_timer(7.0).timeout

	# Reset global variables
	Global.reset()

	# Go back to main menu
	ScreenTrans.change_scene("res://scenes/screens/main_menu.tscn", 3)
