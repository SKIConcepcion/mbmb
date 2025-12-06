extends Area2D

var player_entered = false

# Mapping lock node names → Global flag variable names
var lockables := {
	"BedroomLock": "bedroom_door_lock",
	"BathroomLock": "bathroom_door_lock",
	"FrontDoorLock": "front_door_lock"
}

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_entered = false

func _process(_delta: float) -> void:
	if player_entered and Input.is_action_just_pressed("interact"):
		if self.name in lockables:
			GlobalSfx.door_lock.play()

			var flag_name = lockables[self.name]
			var current = Global.get(flag_name)

			# Toggle lock/unlock
			Global.set(flag_name, not current)
