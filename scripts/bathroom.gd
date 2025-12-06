extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var door: AnimatedSprite2D = $Items/bathroom_door
@onready var elesi: Sprite2D = $Items/elesi
@onready var fan: AudioStreamPlayer2D = $Sounds/Fan
@onready var bathroom_door_01: Area2D = $Triggers/BathroomDoor01
@onready var water_01: Sprite2D = $Items/water_01
@onready var water_02: Sprite2D = $Items/water_02

@onready var water_01_sfx: AudioStreamPlayer2D = $Sounds/Water01
@onready var water_02_sfx: AudioStreamPlayer2D = $Sounds/Water02


@onready var darkness: CanvasModulate = $Darkness


const ELESI_SPIN_SPEED := 5.0   # radians per second (≈115°/sec)


func _process(delta: float) -> void:

	# 🔄 Spin elesi
	elesi.rotation -= ELESI_SPIN_SPEED * delta

	if Global.bathroom_door_lock:
		door.frame = 1
		bathroom_door_01.set_deferred("monitoring", false) 
		bathroom_door_01.set_deferred("monitorable", false) 
	else:
		door.frame = 0
		bathroom_door_01.set_deferred("monitoring", true) 
		bathroom_door_01.set_deferred("monitorable", true) 



	water_01.visible = Global.bathroom_faucet_01_on
	if Global.bathroom_faucet_01_on:
		if not water_01_sfx.playing:
			water_01_sfx.play()
	else:
		if water_01_sfx.playing:
			water_01_sfx.stop()


	water_02.visible = Global.bathroom_faucet_02_on
	if Global.bathroom_faucet_02_on:
		if not water_02_sfx.playing:
			water_02_sfx.play()
	else:
		if water_02_sfx.playing:
			water_02_sfx.stop()
