extends Node2D

@onready var prompt: AnimatedSprite2D = $Prompt

var prompt_tween: Tween
var fade_tween: Tween
var player_inside: bool = false 


func _ready() -> void:
	prompt.visible = false
	prompt.modulate.a = 0.0   #


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true

		if Global.on_bed:
			return

		match self.name:
			"sleep":
				prompt.frame = 4

			"food", "feed":
				prompt.frame = 5

			"key":
				prompt.frame = 14

			"hide", "hide_02":
				prompt.frame = 6

			"bedroom_door_lock", "bathroom_door_lock", "front_door_lock":
				prompt.frame = 1

			"door_01", "door_02", "door_03", "door_06":
				prompt.frame = 3

			"uh_door_05", "conv_door_01", "locked_door_01", "locked_door_02", "locked_door_03", "locked_door_04", "locked_door_05", "mr_door_lock":
				prompt.frame = 7

			"bedroom_door_01":
				if Global.bedroom_door_lock:
					prompt.frame = 7
				else:
					prompt.frame = 3

			"bathroom_door_01":
				if Global.bathroom_door_lock:
					prompt.frame = 7
				else:
					prompt.frame = 3

			"front_door_01":
				if Global.front_door_lock:
					prompt.frame = 7
				else:
					if Global.has_house_key:
						prompt.frame = 3
					else:
						prompt.frame = 13

			"light":
				prompt.frame = 8

			"bathroom_faucet_01", "bathroom_faucet_02", "kitchen_faucet_01":
				prompt.frame = 9

			"stairs_down":
				prompt.frame = 10

			"stairs_up":
				prompt.frame = 11
				
			"pill_01":
				prompt.frame = 12

			"dialogue_text", "interact_01", "interact_02":
				prompt.frame = 12

		_fade_in_prompt()
		_start_prompt_bobble()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
		_fade_out_prompt()
		_stop_prompt_bobble()


func _start_prompt_bobble() -> void:
	_stop_prompt_bobble()  # stop old tween if any
	var original_pos := prompt.position
	prompt_tween = create_tween().set_loops()

	prompt_tween.tween_property(prompt, "position", original_pos + Vector2(0, -3), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	prompt_tween.tween_property(prompt, "position", original_pos, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_prompt_bobble() -> void:
	if prompt_tween and prompt_tween.is_valid():
		prompt_tween.kill()
		prompt_tween = null
	prompt.position = prompt.position.round()



func _fade_in_prompt() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	prompt.visible = true
	fade_tween = create_tween()
	fade_tween.tween_property(prompt, "modulate:a", 1.0, 0.2)  


func _fade_out_prompt() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(prompt, "modulate:a", 0.0, 0.3) 
	fade_tween.tween_callback(func(): prompt.visible = false)


func _process(_delta: float) -> void:
	if Global.on_bed or Global.hidden:
		_stop_prompt_bobble()
		_fade_out_prompt()
