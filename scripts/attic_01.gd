extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_sprite = player.get_node("AnimatedSprite2D")
@onready var player_light = player.get_node("GlowstickLight")

@onready var clouds: Sprite2D = $Items/clouds
@onready var light_01: PointLight2D = $Items/light_01

@onready var darkness: CanvasModulate = $Darkness
@onready var wallet_01: Area2D = $Items/Wallet01

@onready var auto_dialogue_mon_05: Area2D = $Texts/AutoDialogueMon05
@onready var auto_dialogue_mon_06: Area2D = $Texts/AutoDialogueMon06
@onready var dialogue_mon_05: Area2D = $Texts/DialogueMon05


# ☁️ Cloud movement settings
const CLOUD_SPEED := 25.0       # pixels per second
const CLOUD_LEFT_LIMIT := 550  # x-position before snapping back
const CLOUD_START_X := 955    # starting x-position (off-screen right)


func _ready() -> void:
	if Global.has_money:
		wallet_01.queue_free()
		
	if !Global.wallet_loc_known:
		wallet_01.queue_free()
		
	if Global.current_day != 1:
		auto_dialogue_mon_05.queue_free()
		auto_dialogue_mon_05.queue_free()
		dialogue_mon_05.queue_free()



func _process(delta: float) -> void:

	# ☁️ Move clouds
	var cloud_x := clouds.position.x - CLOUD_SPEED * delta
	if cloud_x <= CLOUD_LEFT_LIMIT:
		cloud_x = CLOUD_START_X
	clouds.position.x = cloud_x
