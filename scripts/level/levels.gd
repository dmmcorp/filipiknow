extends Control

@onready var chapter_number_label = $CenterContainer/TextureRect/HBoxContainer/ChapterNo
@onready var chapter_title_label = $CenterContainer/TextureRect/HBoxContainer/ChapterTitle
@onready var grid_container = $CenterContainer/TextureRect/GridContainer
@onready var levels_container = $CenterContainer
@onready var anim_player = $AnimationPlayer
@onready var touch_btn = $"../TouchScreenButton"
@onready var this = $"."
@onready var level_text = $CenterContainer/TextureRect/Level
var levels
var resources
signal level_pressed(index)
func _ready() -> void:
	Globals.level_grid_container = grid_container
	Globals.levels_node = self  # register myself in Globals
	levels_container.visible = false
	#level_button.connect("toggled", Callable(self, "_on_level_button_toggled"))
	Globals.access_grid_buttons()

func instantiate_question_scene():
	var questions_scene = preload("res://scenes/main/question.tscn")
	var questions_instance = questions_scene.instantiate()
	get_parent().add_child(questions_instance)
	#Globals.touch_btn.hide()
	
func remove_question_scene():
	var target = get_node_or_null("res://scenes/main/question.tscn")
	if target:
		target.queue_free()

func get_level_resources(selected_level: int):
	if Globals.chapter_resource.result.has("levels"):
		for game in Globals.chapter_resource.result["levels"]:
			if int(game.level) == float(selected_level):
				Globals.selected_level = game
				print("This is the Selected Level",Globals.selected_level)

#function for toggling the levels menu
func _on_level_button_toggled(toggled_on: bool) -> void:
	this.visible = true
	if toggled_on:
		this.visible = true
		levels_container.visible = true
		anim_player.play("show_levels") 
 	
	else:
		anim_player.play_backwards("show_levels")
		await anim_player.animation_finished  
		levels_container.visible = false
		#Globals.touch_btn.show()
		this.visible = false


func _on_texture_button_button_down() -> void:
	btn_animation_pressed()
	
func btn_animation_pressed():
	anim_player.play_backwards("show_levels")
	await anim_player.animation_finished  
	levels_container.visible = false
	#level_button.set_block_signals(true)
	#level_button.button_pressed = false
	#level_button.set_block_signals(false)
	#Globals.touch_btn.show()
	this.visible = false
	Globals.input_enabled = true
	
