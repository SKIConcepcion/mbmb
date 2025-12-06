extends Area2D

var player: Node = null 

@onready var sprite: Sprite2D = $Sprite2D
@export var pill_amount: int = 1  

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body 

func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null 

func _process(_delta: float) -> void:
	if player and Input.is_action_just_pressed("interact"):
		if self.name == "ConvPill":
			Global.conv_pill_taken = true

		if self.name == "LowerHallwayPill":
			Global.lh_pill_taken = true

		GlobalSfx.pickup.play()
		player.pills += pill_amount
		Global.player_pill_count = player.pills
		player.update_pill_count_label()
		queue_free()
