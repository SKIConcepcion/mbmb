extends Node2D

@onready var clerk: AnimatedSprite2D = $Clerk
@onready var player: CharacterBody2D = $Player

@onready var food_02: Area2D = $Triggers/Food02
@onready var herod: AnimatedSprite2D = $Herod
@onready var sprite_2d: Sprite2D = $Triggers/Food02/Sprite2D
@onready var auto_dialogue_tues_06: Area2D = $Texts/AutoDialogueTues06
@onready var conv_pill: Area2D = $Items/ConvPill

var player_inside := false
var player_ref: Node2D = null

var foods := {
	"Food02": "has_food"
}

func _ready() -> void:
	if Global.current_day != 2:
		auto_dialogue_tues_06.queue_free()
	
	if Global.conv_pill_taken:
		conv_pill.queue_free()


func _process(delta: float) -> void:
	if player.position.x < -1985:
		clerk.flip_h = true
	else:
		clerk.flip_h = false

	if Global.day_2_trigger:
		herod.visible = true
	else:
		herod.visible = false

	if player_inside and Input.is_action_just_pressed("interact"):
		if Global.has_money:
			buy_food()
		else:
			player_ref.dialogue_text = "I need money to buy the baby formula"
			GlobalSfx.hm.play()
			player_ref.update_dialogue_label()


func _on_conv_food_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true
		player_ref = body


func _on_conv_food_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
		player_ref = null

func buy_food() -> void:
	if Global.current_day == 2:
		Global.day_2_trigger = true

	if Global.current_day == 3:
		Global.day_3_trigger = true
	
	GlobalSfx.cash_register.play()
	var flag_name = foods["Food02"]
	Global.set(flag_name, true)
	player_ref.add_ui_item(sprite_2d.texture)
	food_02.queue_free()
