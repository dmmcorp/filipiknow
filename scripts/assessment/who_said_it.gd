extends Control

@onready var question_label = $TextureRect/MarginContainer/VBoxContainer/QuestionContainer/QuestionLabel
@onready var quote_label = $TextureRect/MarginContainer/VBoxContainer/QuoteContainer/PanelContainer/MarginContainer/QuoteLabel
@onready var options_grid_container = $TextureRect/MarginContainer/VBoxContainer/OptionsContainer/GridContainer
# Called when the node enters the scene tree for the first time.
var correct_answer := ""
var current_answer
var options
var who_saide_it
var max_score
var time_limit

signal submit_assessment(player_answer:String, correct_answer: String, max_score:float)
signal option_selected(selected_option)

func _ready() -> void:
	_show_images()
	_set_question_and_quote()
	for option in options_grid_container.get_children():
		option.connect("option_selected",Callable(self, "_on_option_selected"))

func setup(data: Dictionary):
	who_saide_it = data.whoSaidIt
	options = who_saide_it.options
	max_score = data.points
	time_limit = data.time_limit

func _show_images():
	if options:
		for i in range(options_grid_container.get_child_count()):
			var option_instance = options_grid_container.get_child(i)
			var option_data = options[i]
			print(option_data)
			if option_data.isCorrect:
				correct_answer = option_data.name
			option_instance.set_content(
				option_data.name,
				option_data.image as Texture2D  # make sure this is a Texture2D!
			)

func _on_option_selected(selected_option):
	for i in range(options_grid_container.get_child_count()):
		var option_instance = options_grid_container.get_child(i)
		var option_data = options[i]
		if option_instance == selected_option:
			option_instance.panel_bg.visible = true
			current_answer = option_data.name 
		else:
			option_instance.panel_bg.visible = false
		
func _set_question_and_quote():
	question_label.text = who_saide_it.question
	quote_label.text = "\"%s\"" % who_saide_it.quote
	
func _on_submit_button_button_down() -> void:
	print(current_answer, correct_answer, max_score)
	emit_signal("submit_assessment", current_answer, correct_answer, max_score, time_limit)
