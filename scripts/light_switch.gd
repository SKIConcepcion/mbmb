extends Area2D

var player_entered = false

# Map lamp nodes → Global flags
var lamps := {
	"UpperHallwayLamp": "uh_lamp_light"
}

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		if self.name in lamps:
			GlobalSfx.light_switch.play() # 🔊 or swap with a lamp SFX if you want

			var flag_name = lamps[self.name]
			var current = Global.get(flag_name)

			# Toggle lamp on/off
			Global.set(flag_name, not current)
