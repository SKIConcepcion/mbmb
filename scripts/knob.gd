extends Area2D

var player_entered = false

# Mapping lock node names → Global flag variable names
var knobs := {
	"BathroomFaucet01": "bathroom_faucet_01_on",
	"BathroomFaucet02": "bathroom_faucet_02_on",
	"KitchenFaucet": "kitchen_faucet_on"
}

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		if self.name in knobs:
			GlobalSfx.light_switch.play()

			var flag_name = knobs[self.name]
			var current = Global.get(flag_name)
			
			print(flag_name)

			# Toggle lock/unlock
			Global.set(flag_name, not current)
