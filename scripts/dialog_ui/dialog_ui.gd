extends Control

@onready var dialog_text = $PanelContainer/MarginContainer/Text
@onready var character = $"../Character"
@onready var description_dialog = $CenterContainer
var current_speaker_name: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func get_current_index() -> int:
	return dialog_text.current_index
	
func set_index(back: bool = false):
	dialog_text.set_index(back)
	current_speaker_name = dialog_text.get_current_speaker()
	description_dialog.visible = false
	
