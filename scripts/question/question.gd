extends Control

@onready var parent = $"."
@onready var  submit_btn = $CenterContainer/TextureRect/VBoxContainer/CenterContainer/SubmitButton
@onready var grid_container = $CenterContainer/TextureRect/VBoxContainer/AnswerInputContainer/GridContainer
@onready var popup_container = $PopupContainer
@onready var popup_text = $PopupContainer/TextureRect/MarginContainer/VBoxContainer/PopupText
@onready var popup_anim = $PopupContainer/AnimationPlayer
#@onready var question_container_anim = $CenterContainer/AnimationPlayer
@onready var level_label = $CenterContainer/TextureRect/Level
@onready var question_label = $CenterContainer/TextureRect/VBoxContainer/QuestionContainer/QuestionLabel
# Called when the node enters the scene tree for the first time.
@onready var control_node = $CenterContainer/TextureRect/VBoxContainer/MarginContainer/Control
func _ready() -> void:
	#question_container_anim.play("slide-down")
	grid_container.connect("answer_submitted", Callable(self, "_on_show_result_popup"))
	#question_container_anim.play("slide-down")
	control_node.connect("question_ready",  Callable(self, "_on_question_ready"))
	level_label.text = "Level " + str(int(Globals.selected_level.level))
	
func _on_question_ready(question:String):
	question_label.text = question
func _on_show_result_popup(success: bool, points: float) -> void:
	print(success)
	
	if success:
		popup_text.bbcode_text = "[color=green][b]Tamang Sagot![/b][/color]\n + [color=blue]%s puntos[/color]" % points
	else:
		popup_text.text = "[color=red][b]Maling Sagot[/b][/color]\nSubukan Muli!"

	# Reset scroll and make visible
	popup_container.visible = true
	Globals.access_grid_buttons()
	# optional pop-in animation
	if popup_anim and popup_anim.has_animation("pop-up"):
		popup_anim.play("pop=up")


func _on_close_button_button_down() -> void:
	#Globals.touch_btn.show()
	Globals.input_enabled = true
	parent.visible = false


func _on_texture_button_button_down() -> void:
	Globals.selected_level


func _on_okay_button_button_down() -> void:
	popup_container.visible = false
