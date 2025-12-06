extends Node

@onready var door: AudioStreamPlayer = $Door
@onready var door_lock: AudioStreamPlayer = $DoorLock
@onready var box_crunch: AudioStreamPlayer = $BoxCrunch
@onready var cabinet: AudioStreamPlayer = $Cabinet
@onready var bush: AudioStreamPlayer = $Bush
@onready var light_switch: AudioStreamPlayer = $LightSwitch
@onready var button_click: AudioStreamPlayer = $ButtonClick
@onready var blanket: AudioStreamPlayer = $Blanket
@onready var stairs: AudioStreamPlayer = $Stairs
@onready var pills: AudioStreamPlayer = $Pills
@onready var conv_door: AudioStreamPlayer = $ConvDoor
@onready var conv_music: AudioStreamPlayer = $ConvMusic
@onready var hm: AudioStreamPlayer = $Hm
@onready var cash_register: AudioStreamPlayer = $CashRegister
@onready var pickup: AudioStreamPlayer = $Pickup
@onready var fridge: AudioStreamPlayer = $Fridge
@onready var paper: AudioStreamPlayer = $Paper
@onready var music_box: AudioStreamPlayer = $MusicBox


func fade_in_music_box(duration: float = 2.5, target_volume: float = 0.0) -> void:
	music_box.volume_db = -50.0 
	music_box.play()
	var tween := create_tween()
	tween.tween_property(music_box, "volume_db", target_volume, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func fade_out_music_box(duration: float = 2.0) -> void:
	var tween := create_tween()
	tween.tween_property(music_box, "volume_db", -80.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func ():
		music_box.stop()
	)
	
