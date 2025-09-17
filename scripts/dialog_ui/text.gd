extends RichTextLabel

@onready var dialog_text = $"."
@onready var speaker_name_left = $"../SpeakerNameLeft"
@onready var description_dialog = $"../../../../CenterContainer"
@onready var description_text = $"../../../../CenterContainer/TextureRect/Description"
@onready var animation_player = $"../../../../CenterContainer/AnimationPlayer"
@onready var speaker_container = $"../SpeakerNameLeft"

const ANIMATION_SPEED : int = 30 
var animate_text : bool = false
var current_visible_character: int =  0
var current_index: int = 0
var current_speaker: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_first_speaker()
	dialog_text.visible_ratio = 0
	animate_text = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animate_text:
		if dialog_text.visible_ratio < 1:
			dialog_text.visible_ratio += (2.0/dialog_text.text.length()) * (ANIMATION_SPEED * delta)
		else:
			animate_text = false
	

func display_first_speaker():
	if Globals.chapter_resource and Globals.chapter_resource.has("result"):
		print("gasol")
		process_lines()
		current_index = 0
	else:
		return


func process_lines():
	var text = Globals.chapter_resource.result.scenes[current_index].text
	var scene_data = Globals.chapter_resource.result.scenes[current_index]
	display_speaker_text(text)
	
	if scene_data.has("speaker") and scene_data.speaker and scene_data.speaker.has("name"):
		speaker_container.visible = true
		display_speaker_name_left(Globals.chapter_resource.result.scenes[current_index].speaker.name)
		current_speaker = Globals.chapter_resource.result.scenes[current_index].speaker.name
	else:
		speaker_container.visible = false
	

func get_current_speaker()->String:
	return current_speaker

func display_speaker_text(text:String):
	var scene =  Globals.chapter_resource.result.scenes[current_index]
	if scene.has("highlighted_word"):
		set_bold_word(text, scene.highlighted_word.word)
	else:
		dialog_text.text = text

func display_speaker_name_left(name:String):
	speaker_name_left.text = name + ":" 
	
func set_index(back: bool = false):
	dialog_text.visible_ratio = 0
	animate_text = true
	if back:
		if current_index > 0:
			current_index -= 1
			process_lines()
	if back == false and current_index != len(Globals.chapter_resource.result.scenes) - 1:
		current_index += 1
		process_lines()

func set_bold_word(text: String, word: String) -> void:
	dialog_text.bbcode_enabled = true
	var bolded_text := text.replace(word, "[color=black][b][url=vocabulary]%s[/url][/b][/color]" % word)
	dialog_text.text = bolded_text

func _on_meta_clicked(meta: Variant) -> void:
	if meta == "vocabulary":
		description_dialog.visible = true
		if Globals.touch_btn is TouchScreenButton:
			Globals.touch_btn.hide()
		if Globals.chapter_resource.result.scenes[current_index].has("highlighted_word"):
			var scene_data = Globals.chapter_resource.result.scenes[current_index]
			if scene_data.highlighted_word and scene_data.highlighted_word.has("definition"):
				description_text.text = scene_data.highlighted_word.definition
				animation_player.play("slide_up")
			else:
				description_text.text = "No definition available."
				animation_player.play("slide_up")
		else:
			description_text.text = "Invalid scene index."
			animation_player.play("slide_up")


func _on_texture_button_button_down() -> void:
	animation_player.play_backwards("slide_up")
	description_dialog.visible = true
	await animation_player.animation_finished
	if Globals.touch_btn is TouchScreenButton:
		Globals.touch_btn.show()
