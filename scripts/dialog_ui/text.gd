extends RichTextLabel

@onready var dialog_text = $"."
@onready var speaker_name_left = $"../../../SpeakerLeft/SpeakerNameLeft"

const ANIMATION_SPEED : int = 30
var animate_text : bool = true
var current_visible_character: int =  0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog_text.visible_ratio = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animate_text:
		if dialog_text.visible_ratio < 1:
			dialog_text.visible_ratio += (1.0/dialog_text.text.length()) * (ANIMATION_SPEED * delta)
		else:
			animate_text = false
			
func change_line(speaker: String, text: String, index: int):
	pass
