extends Control

@onready var animation = $AnimationPlayer
@onready var node = $"."
# Called when the node enters the scene tree for the first time.

func change_scene(target: String):
	await animation.animation_finished
	get_tree().change_scene_to_file(target)
	
