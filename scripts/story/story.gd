extends Control

@onready var BG = $BG
@onready var speaker_name_left = $DialogUi/SpeakerLeft/SpeakerNameLeft as RichTextLabel
@onready var dialog_text = $PanelContainer/MarginContainer/Text
@onready var quit_btn = $Quit
@onready var back_btn = $Back
@onready var dialog_ui = $DialogUi
@onready var character = $Character
@onready var image_loader = ImageLoader.new()

var index: int
var current_speaker_name: String
var character_images: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_speaker_name = dialog_ui.current_speaker_name
	auto_place_character()

func _unhandled_input(event):
	if event.is_action_pressed("next_line"):
		if index < len(Globals.level_resource.result.scenes) - 1:
			dialog_ui.set_index()
			index = dialog_ui.get_current_index()
			auto_place_character()
			
	
func _on_back_button_down() -> void:
	dialog_ui.set_index(true)
	index = dialog_ui.get_current_index()
	auto_place_character()
	
func auto_place_character():
	print(index)
	var image_url = Globals.level_resource.result.scenes[index].speaker.image
	var char_name =  Globals.level_resource.result.scenes[index].speaker.name
	character.assign_character(image_url, char_name)


func _on_quit_button_down() -> void:
	SceneTransition.transition_move_left("res://scenes/main/novel_select.tscn")
