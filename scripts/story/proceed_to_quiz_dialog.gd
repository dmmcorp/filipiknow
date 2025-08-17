extends Control

@onready var close_btn = $TextureRect/TextureButton
@onready var animation_player = $"../AnimationPlayer"
@onready var touch_btn = $"../TouchScreenButton"
@onready var dialog = $"."
@onready var proceed_btn = $TextureRect/Button
@onready var levels_btn = $"../LevelsButton"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func close_proceed_dialog():
	animation_player.play_backwards("pop_up")
	await animation_player.animation_finished
	dialog.visible = false

#close btn signal
func _on_texture_button_button_down() -> void:
	close_proceed_dialog()
	touch_btn.show()
	Globals.input_enabled = true
	
#yes btn signal
func _on_button_button_down() -> void:
	close_proceed_dialog()
	levels_btn.visible = true
	Globals.input_enabled = false
	print(Globals.input_enabled)
