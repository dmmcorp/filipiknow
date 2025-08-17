extends Control

@onready var chapter_number_label = $CenterContainer/TextureRect/HBoxContainer/ChapterNo
@onready var chapter_title_label = $CenterContainer/TextureRect/HBoxContainer/ChapterTitle
@onready var grid_container = $CenterContainer/TextureRect/GridContainer
@onready var levels_container = $CenterContainer
@onready var anim_player = $AnimationPlayer
@onready var touch_btn = $"../TouchScreenButton"
@onready var level_button = $"../LevelsButton"
@onready var this = $"."
var levels
var resources
var progress
func _ready() -> void:
	levels_container.visible = false
	level_button.connect("toggled", Callable(self, "_on_level_button_toggled"))
	access_grid_buttons()

func assign_levels():
	pass
func access_grid_buttons():
	progress = Globals.progress_data
	for child in grid_container.get_children():
		var index = grid_container.get_children().find(child)
		print(index > progress.progress.current_level)
		if child is TextureButton:
			# Example: print the button name
			print("Button name:", child.name)
			if not child.is_connected("button_down", Callable(self, "_on_level_button_button_down").bind(index)):
				child.connect("button_down", Callable(self, "_on_level_button_button_down").bind(index))
			# You can also change properties
			if  progress.progress.current_level > index:
				for subchild in child.get_children():
					if subchild is TextureRect:
						print("Found TextureRect:", subchild.name)
						subchild.visible = false
					if subchild is Label:
						subchild.visible = true
			else:
				child.disabled = true  # Disable button
func _on_level_button_button_down(index):
	print("Button down on index:", index)
	# Your animation + toggle reset logic here
	anim_player.play_backwards("show_levels")
	await anim_player.animation_finished
	levels_container.visible = false
	level_button.button_pressed = false
	
func _on_level_button_toggled(toggled_on: bool) -> void:
	this.visible = true
	if toggled_on:
		this.visible = true
		levels_container.visible = true
		anim_player.play("show_levels") 
		touch_btn.hide()
	else:
		anim_player.play_backwards("show_levels")
		await anim_player.animation_finished  # ✅ Wait for signal
		levels_container.visible = false
		touch_btn.show()
		this.visible = false


func _on_texture_button_button_down() -> void:
	anim_player.play_backwards("show_levels")
	await anim_player.animation_finished  # ✅ Wait for signal
	levels_container.visible = false
	level_button.set_block_signals(true)
	level_button.button_pressed = false
	level_button.set_block_signals(false)
	touch_btn.show()
	this.visible = false
