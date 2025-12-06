extends Area2D

var entered = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		entered = false

func _process(_delta: float) -> void:
	if entered and Input.is_action_just_pressed("interact"):
		if self.name == "BedroomDoor01":
			_enter_door(Vector2(570, -70.0), "res://scenes/areas/upper_hallway_01.tscn", 1)

		elif self.name == "UpperHallwayDoor01A":
			_enter_door(Vector2(570, -70.0), "res://scenes/areas/bedroom_01.tscn", 1)

		elif self.name == "UpperHallwayDoor01B":
			_enter_door(Vector2(84, -70.0), "res://scenes/areas/bathroom_01.tscn", 1)
			
		elif self.name == "UpperHallwayDoor01C":
			_enter_door(Vector2(80, -70.0), "res://scenes/areas/attic_01.tscn", 2)

		elif self.name == "UpperHallwayDoor01D":
			_enter_door(Vector2(2720, -70.0), "res://scenes/areas/lower_hallway_01.tscn", 2)

		elif self.name == "BathroomDoor01":
			_enter_door(Vector2(-835, -70.0), "res://scenes/areas/upper_hallway_01.tscn", 1)

		elif self.name == "AtticDoor01":
			_enter_door(Vector2(-302, -70.0), "res://scenes/areas/upper_hallway_01.tscn", 2)

		elif self.name == "LowerHallwayDoor01A":
			if Global.has_house_key:
				_enter_door(Vector2(0.0, -70.0), "res://scenes/areas/outside_01.tscn", 1)

		elif self.name == "LowerHallwayDoor01B":
			_enter_door(Vector2(1534, -70.0), "res://scenes/areas/kitchen_01.tscn", 2)

		elif self.name == "LowerHallwayDoor01C":
			_enter_door(Vector2(2400, -70.0), "res://scenes/areas/upper_hallway_01.tscn", 2)

		elif self.name == "KitchenDoor01B":
			_enter_door(Vector2(1534, -70.0), "res://scenes/areas/lower_hallway_01.tscn", 2)

		elif self.name == "OutsideDoor01A":
			_enter_door(Vector2(0.0, -70.0), "res://scenes/areas/convenience_store_01.tscn", 3)

		elif self.name == "OutsideDoor01B":
			_enter_door(Vector2(-836.0, -70.0), "res://scenes/areas/lower_hallway_01.tscn", 1)

		elif self.name == "ConvDoor01B":
			_enter_door(Vector2(-7161, -70.0), "res://scenes/areas/outside_01.tscn", 3)


func _enter_door(spawn_position: Vector2, scene_path: String, door: int = 1) -> void:
	Global.spawn_position = spawn_position
	
	if door == 1:
		GlobalSfx.door.play()
	elif door == 2:
		GlobalSfx.stairs.play()
	elif door == 3:
		GlobalSfx.conv_music.play()
		GlobalSfx.conv_door.play()
		
		
	Global.can_move = false  # 🚫 disable movement
	ScreenTrans.change_scene(scene_path)

	await get_tree().create_timer(1.0).timeout
	Global.can_move = true
