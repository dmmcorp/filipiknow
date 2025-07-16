extends Control
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var panel = $CanvasLayer/Panel
@onready var container = $CanvasLayer/CenterContainer
func change_scene(target: String, no_http_request: bool = true, type: String = 'dissolve')-> void:
	if type == "move_left":
		transition_move_left(target, no_http_request)
	else:
		transition_dissolve(target, no_http_request)

func transition_dissolve(target: String, no_http_request = true) -> void:
	animation_player.play('dissolve')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	if no_http_request:
		animation_player.play_backwards("dissolve")
		await animation_player.animation_finished

func transition_move_left(target: String, no_http_request = true) -> void:
	animation_player.play('move_left')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	if no_http_request:
		animation_player.play_backwards("move_left")
		await animation_player.animation_finished



func play_backward(animation):
	animation_player.play_backwards(animation)
	await animation_player.animation_finished
