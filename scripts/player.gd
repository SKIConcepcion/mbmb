extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var walking_sfx: AudioStreamPlayer = $WalkingSfx
@onready var glowstick: PointLight2D = $GlowstickLight
@onready var glowstick_sfx: AudioStreamPlayer = $GlowstickSfx
@onready var player_darkness: ColorRect = $CanvasLayer/PlayerDarkness

@onready var left_button: TextureButton = $ButtonLayer/LeftButton
@onready var right_button: TextureButton = $ButtonLayer/RightButton
@onready var light_button: TextureButton = $ButtonLayer/LightButton
@onready var interact_button: TextureButton = $ButtonLayer/InteractButton
@onready var pill_button: TextureButton = $ButtonLayer/PillButton
@onready var pill_count: Label = $ButtonLayer/PillButton/Label

@onready var dialogue: Label = $CanvasLayer/Dialogue


const SPEED = 160.0

const MAX_ENERGY := 1.5    
const MIN_ENERGY := 0.0  
const INIT_ENERGY := 0.7  
const DECAY_RATE := 0.15
const RESTORE_AMOUNT := 0.5  

const MAX_RADIUS := 2.0
const MIN_RADIUS := 1.0
const INIT_RADIUS := 1.6
const PILL_RADIUS_BOOST := 0.3

var move_left := false
var move_right := false

var pills := 0


var dialogue_text := ""



func _ready() -> void:
	global_position = Global.spawn_position
	
	pills = Global.player_pill_count
	update_pill_count_label()
	
	if Global.player_inventory.size() > 0:
		collected_items = Global.player_inventory.duplicate()
		update_ui_items()

	glowstick.shadow_enabled = false
	glowstick.blend_mode = Light2D.BLEND_MODE_ADD
	glowstick.energy = INIT_ENERGY

	var radius = clamp(Global.player_glow_radius, MIN_RADIUS, MAX_RADIUS)
	glowstick.scale = Vector2(radius, radius)

	left_button.connect("button_down", Callable(self, "_on_left_button_down"))
	left_button.connect("button_up", Callable(self, "_on_left_button_up"))
	right_button.connect("button_down", Callable(self, "_on_right_button_down"))
	right_button.connect("button_up", Callable(self, "_on_right_button_up"))
	light_button.connect("pressed", Callable(self, "_on_light_button_pressed"))
	interact_button.connect("pressed", Callable(self, "_on_interact_button_pressed"))
	pill_button.connect("pressed", Callable(self, "_on_pill_button_pressed"))



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Global.can_move:
		handle_movement()
	else:
		stop_movement()

	var new_energy = max(MIN_ENERGY, glowstick.energy - DECAY_RATE * delta)
	if abs(new_energy - glowstick.energy) > 0.001:
		glowstick.energy = new_energy

	if Input.is_action_just_pressed("light"):
		restore_glowstick()

	if Input.is_action_just_pressed("pill_take"):
		take_pill()

	move_and_slide()



#============== MOVEMENT LOGIC ==============#

func handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")

	# Mobile button overrides
	if move_left:
		direction = -1
	elif move_right:
		direction = 1

	if direction != 0:
		velocity.x = direction * SPEED

		if animated_sprite_2d.animation != "moving":
			animated_sprite_2d.play("moving")

		animated_sprite_2d.flip_h = direction < 0

		if not walking_sfx.playing:
			walking_sfx.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")

		if walking_sfx.playing:
			walking_sfx.stop()


func stop_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, SPEED)

	if animated_sprite_2d.animation != "idle":
		animated_sprite_2d.play("idle")

	if walking_sfx.playing:
		walking_sfx.stop()


func _on_left_button_down() -> void:
	move_left = true

func _on_left_button_up() -> void:
	move_left = false

func _on_right_button_down() -> void:
	move_right = true

func _on_right_button_up() -> void:
	move_right = false

func _on_light_button_pressed() -> void:
	restore_glowstick()

func _on_interact_button_pressed() -> void:
	Input.action_press("interact")
	Input.action_release("interact")


#============== PILLS LOGIC ==============#

func _on_pill_button_pressed() -> void:
	if Global.can_move:
		take_pill()


func restore_glowstick() -> void:
	glowstick_sfx.play()
	glowstick.energy = min(MAX_ENERGY, glowstick.energy + RESTORE_AMOUNT)


func take_pill() -> void:
	if pills <= 0:
		print("No pills left!")
		return

	pills -= 1
	Global.player_pill_count = pills  # ✅ Save to persistent variable
	update_pill_count_label()

	var new_radius = clamp(glowstick.scale.x + PILL_RADIUS_BOOST, MIN_RADIUS, MAX_RADIUS)
	glowstick.scale = Vector2(new_radius, new_radius)
	Global.player_glow_radius = new_radius

	glowstick_sfx.play()
	print("Pill taken! Light radius:", new_radius)



func update_pill_count_label() -> void:
	if pill_count and pill_count.is_inside_tree():
		pill_count.text = str(pills)
	Global.player_pill_count = pills  # ✅ Always keep saved




#============== DIALOGUE LOGIC ==============#

func update_dialogue_label() -> void:
	if dialogue and dialogue.is_inside_tree():
		dialogue.text = dialogue_text
		dialogue.visible = true
		
		var timer = get_tree().create_timer(4.0)
		
		timer.timeout.connect(func():
			if dialogue and dialogue.is_inside_tree():
				dialogue.visible = false
		)



#============== ITEMS LOGIC ==============#

const MAX_ITEMS := 3
var collected_items: Array = []

@onready var ui_items := [
	$CanvasLayer/Items/Item0,
	$CanvasLayer/Items/Item1,
	$CanvasLayer/Items/Item2,
]

func add_ui_item(texture: Texture2D) -> void:
	if collected_items.size() >= MAX_ITEMS:
		collected_items.pop_front()

	collected_items.append(texture)
	Global.player_inventory = collected_items.duplicate()
	update_ui_items()


func update_ui_items() -> void:
	for icon in ui_items:
		icon.visible = false

	var index = MAX_ITEMS - 1
	for texture in collected_items:
		ui_items[index].texture = texture
		ui_items[index].visible = true
		index -= 1

func remove_all_items() -> void:
	collected_items.clear()
	Global.player_inventory.clear()
	for icon in ui_items:
		icon.visible = false
		icon.texture = null
