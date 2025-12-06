extends Area2D

var player_inside := false
var player_ref: Node2D = null

var wallets := {
	"Wallet01": "has_money"
}

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true
		player_ref = body  # store reference to use later

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
		player_ref = null

func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		pickup_food()

func pickup_food() -> void:
	print(name)
	if name in wallets and player_ref:
		GlobalSfx.pickup.play()

		var flag_name = wallets[name]
		Global.set(flag_name, true)

		player_ref.add_ui_item($Sprite2D.texture)

		queue_free()
