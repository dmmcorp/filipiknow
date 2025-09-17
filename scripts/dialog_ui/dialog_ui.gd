extends Control

@onready var dialog_text = $PanelContainer/MarginContainer/VBoxContainer/Text
@onready var character = $"../Character"
@onready var description_dialog = $CenterContainer
@onready var current_bg = $"../StoryBg"
var current_speaker_name: String = ""

func _ready() -> void:
	pass
func get_current_index() -> int:
	return dialog_text.current_index
	
func set_index(back: bool = false):
	dialog_text.set_index(back)
	current_speaker_name = dialog_text.get_current_speaker()
	description_dialog.visible = false
	
