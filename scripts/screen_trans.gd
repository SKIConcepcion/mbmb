extends CanvasLayer

func change_scene(target: String, delay: int = 1) -> void:
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(delay).timeout
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("fade")

func death_scene(target: String) -> void:
	call_deferred("_do_death_scene", target)

func _do_death_scene(target: String) -> void:
	get_tree().change_scene_to_file(target)
