extends Area2D

var player_entered = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		# Only toggle once per press
		if Global.on_bed:
			Global.on_bed = false   # wake up
			Global.can_move = true
		else:
			Global.on_bed = true    # go to bed
			Global.can_move = false
