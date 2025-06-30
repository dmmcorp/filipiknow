extends Control
@onready var animation_player = $CanvasLayer/AnimationPlayer
func change_scene(target: String, type: String = 'dissolve')-> void:
	if type == "move_left":
		transiction_move_left(target)
	else:
		transiction_dissolve(target)

func transiction_dissolve(target: String) -> void:
	animation_player.play('dissolve')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	animation_player.play_backwards("dissolve")

func transiction_move_left(target: String) -> void:
	animation_player.play('move_left')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	animation_player.play_backwards("move_left")
