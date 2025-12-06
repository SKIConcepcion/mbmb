extends Area2D

var player_entered = false

# Mapping node names to Global variables
var hideables := {
	"Toybox": "on_toybox",
	"JanitorialCabinet": "on_janitorial_cabinet",
	"LargePlant01": "on_large_plant_01",
	"LargePlant02": "on_large_plant_02",
	"LargePlant03": "on_large_plant_03",
	"Tree01": "on_tree_01"
}

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		if self.name in hideables:
			var flag_name = hideables[self.name]

			# ✅ Check if Global has this variable
			if flag_name in Global:
				var current = Global.get(flag_name)

				# Toggle hide state
				var new_state = not current
				Global.set(flag_name, new_state)

				# Update global hidden + movement lock
				Global.hidden = new_state
				Global.can_move = not new_state
