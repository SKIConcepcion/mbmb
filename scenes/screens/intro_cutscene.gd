extends Node2D

@onready var label: Label = $CanvasLayer/Label
@onready var camera_2d: Camera2D = $Camera2D
@onready var bed: AnimatedSprite2D = $Items/bed
@onready var cabinet: AnimatedSprite2D = $Items/cabinet
@onready var clouds: Sprite2D = $Items/clouds
@onready var elesi: Sprite2D = $Items/elesi
@onready var cabinet_shake: AudioStreamPlayer2D = $Sounds/CabinetShake
@onready var light_01: PointLight2D = $Items/light_01
@onready var light_02: PointLight2D = $Items/light_02
@onready var skip_button: TextureButton = $CanvasLayer/SkipButton

var cabinet_timer: Timer
var label_timer: Timer

var label_messages = [
	"There's a monster beside my bed...",
	"",
	"My father told me that he caught something, but I must feed it every night at 9:17 PM",
	"He says to feed it baby formula... but gave no reason why",
	"He also says to never turn on the house lights as the brightness might lure them in",
	"I’ve always listened. I’ve always been good",
	"But lately, I've been seeing monsters in my dreams...",
	"And sometimes when I am awake."
]

var label_durations = [
	4.0, 
	7.5, 
	6.0,
	5.0,
	6.0,
	4.5,
	4.0,
	4.0
]

var current_label_index = 0
var camera_moved := false

const CLOUD_SPEED := 25.0
const CLOUD_LEFT_LIMIT := -550
const CLOUD_START_X := -100
const ELESI_SPIN_SPEED := 5.0

func _ready() -> void:
	# Cabinet shake timer
	cabinet_timer = Timer.new()
	cabinet_timer.wait_time = 3.0
	cabinet_timer.one_shot = true
	add_child(cabinet_timer)
	cabinet_timer.timeout.connect(_on_cabinet_shake)
	cabinet_timer.start()

	# Label change timer
	label_timer = Timer.new()
	label_timer.one_shot = true
	add_child(label_timer)
	label_timer.timeout.connect(_on_label_change)

	label.text = label_messages[current_label_index]
	label.modulate.a = 1.0
	label_timer.start(label_durations[current_label_index])


func _process(delta: float) -> void:
	var cloud_x := clouds.position.x - CLOUD_SPEED * delta
	if cloud_x <= CLOUD_LEFT_LIMIT:
		cloud_x = CLOUD_START_X
	clouds.position.x = cloud_x
	elesi.rotation -= ELESI_SPIN_SPEED * delta


func _on_cabinet_shake() -> void:
	var original_pos := cabinet.position
	var tween := create_tween()

	for i in range(5):
		var offset := Vector2(randf_range(-1.5, 1.5), randf_range(-0.5, 0.5))
		tween.tween_property(cabinet, "position", original_pos + offset, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(cabinet, "position", original_pos, 0.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		cabinet_shake.play()

	tween.finished.connect(func ():
		cabinet_timer.wait_time = randf_range(5.0, 10.0)
		cabinet_timer.start()
	)


func _on_label_change() -> void:
	current_label_index += 1

	# If we've reached the end of messages, start the fade-out sequence
	if current_label_index >= label_messages.size():
		_start_fade_out()
		return

	label.text = label_messages[current_label_index]

	# Move camera + label after the first label change
	if current_label_index == 1 and not camera_moved:
		camera_moved = true

		var tween := create_tween()

		# Clear the label before movement
		tween.tween_callback(func ():
			label.text = ""
		)
		
		# Fade out label slowly
		tween.tween_property(skip_button, "modulate:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Move camera smoothly to the right
		tween.tween_property(camera_2d, "position:x", 84.0, 2.0)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Move label as well (slide to new position)
		tween.tween_property(label, "position:x", -496.0, 2.0)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Gradually fade light_01 out and light_02 in
		tween.tween_property(light_01, "energy", 0.0, 1.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(light_02, "energy", 1.5, 1.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# Restore the label text after everything finishes
		tween.tween_callback(func ():
			label.text = label_messages[current_label_index]
		)

	label_timer.start(label_durations[current_label_index])


# --- FINAL SEQUENCE ---
func _start_fade_out() -> void:
	var tween := create_tween()

	# Fade out label slowly
	tween.tween_property(label, "modulate:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Fade out the light
	tween.tween_property(light_02, "energy", 0.0, 3.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


	# After fade + zoom, delay a bit, then change scene
	tween.tween_callback(func ():
		await get_tree().create_timer(1.0).timeout
		ScreenTrans.change_scene("res://scenes/screens/tutorial_screen.tscn", 1)
	)

func _on_skip_button_pressed() -> void:
	GlobalSfx.button_click.play()
	ScreenTrans.change_scene("res://scenes/screens/tutorial_screen.tscn", 1)
