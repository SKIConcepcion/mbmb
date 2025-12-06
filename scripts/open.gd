extends Area2D

var player_entered = false

# Mapping lock node names → Global flag variable names
var openables := {
	"KitchenFridge01": "kitchen_fridge_01_open"
}

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		if self.name in openables:
			GlobalSfx.fridge.play()

			var flag_name = openables[self.name]
			var current = Global.get(flag_name)
			
			# Toggle lock/unlock
			Global.set(flag_name, not current)
