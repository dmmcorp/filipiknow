extends Control

@onready var BG = $BG
@onready var speaker_name_left = $CanvasLayer/DialogUi/SpeakerLeft/SpeakerNameLeft as RichTextLabel
@onready var dialog_text = $CanvasLayer/DialogUi/PanelContainer/MarginContainer/Text as RichTextLabel
var current_index: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_first_speaker()

func _input(event):
	if event.is_action_pressed("next_line"):
		if current_index < len(Globals.level_resource.result.scenes) - 1:
			current_index += 1
			process_lines()
func display_first_speaker():
	if Globals.level_resource and Globals.level_resource.has("result"):
		process_lines()
	else:
		return

func process_lines():
	display_speaker_text(Globals.level_resource.result.scenes[current_index].text)
	display_speaker_name_left(Globals.level_resource.result.scenes[current_index].speaker.name)

func display_speaker_text(text:String):
	dialog_text.text = text

func display_speaker_name_left(name:String):
	speaker_name_left.text = name
