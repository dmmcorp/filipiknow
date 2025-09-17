extends Control

@onready var current_bg: TextureRect = $StoryBg
@onready var speaker_name_left: RichTextLabel = $DialogUi/SpeakerLeft/SpeakerNameLeft
@onready var dialog_text: Label = $PanelContainer/MarginContainer/Text
@onready var quit_btn: Button = $Quit
@onready var back_btn: Button = $Back
@onready var dialog_ui: Control = $DialogUi
@onready var character = $Character
@onready var image_loader = ImageLoader.new()
@onready var proceed_to_levels: Control = $ProceedToQuizDialog
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var touch_btn: TouchScreenButton = $CenterContainer/TouchScreenButton
@onready var levels_btn: Button = $LevelsButton
@onready var levels_container = $Levels

var index: int = 0
var current_speaker_name: String
var character_images: Array = []
var line_bg_image
var chapter_bg_image

func _ready() -> void:
	current_speaker_name = dialog_ui.current_speaker_name
	set_bg() # ✅ load first background
	auto_place_character()
	Globals.touch_btn = touch_btn
	Globals.levels_btn = levels_btn
	Globals.touch_btn = touch_btn


func _unhandled_input(event):
	print(index)
	if Globals.input_enabled:
		if event.is_action_pressed("next_line"):
			if index < len(Globals.chapter_resource.result.scenes) - 1:
				dialog_ui.set_index()
				index = dialog_ui.get_current_index()
				set_bg()
				auto_place_character()
			else:
				#levels_btn.visible = true
				Globals.input_enabled = false
				levels_container._on_level_button_toggled(true)
				#Globals.touch_btn.hide()


func _on_back_button_down() -> void:
	dialog_ui.set_index(true)
	index = dialog_ui.get_current_index()
	set_bg()
	auto_place_character()


func auto_place_character():
	var scene = Globals.chapter_resource.result.scenes[index]

	# Default values
	var image_url = ""
	var char_name = ""

	# ✅ Check if speaker exists and has properties
	if scene.has("speaker") and scene.speaker:
		if scene.speaker.has("image"):
			image_url = scene.speaker.image
		if scene.speaker.has("name"):
			char_name = scene.speaker.name
	else:
		pass
	# Assign character (will work even if image_url or char_name is empty)
	character.assign_character(image_url, char_name)

func _on_quit_button_down() -> void:
	SceneTransition.transition_dissolve("res://scenes/main/novel_select.tscn", false)


func _on_touch_screen_button_pressed() -> void:
	if index < len(Globals.chapter_resource.result.scenes) - 1:
		dialog_ui.set_index()
		index = dialog_ui.get_current_index()
		set_bg()
		auto_place_character()
	else:
		levels_container._on_level_button_toggled(true)
		animation_player.play("pop_up")
		#Globals.touch_btn.hide()


func _on_levels_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func set_bg():
	line_bg_image = Globals.chapter_resource.result.scenes[index].scene_bg_image
	chapter_bg_image = Globals.chapter_resource.result.novel_metadata.bg_image
	var texture: Texture2D = null
	print(current_bg.texture)
	if line_bg_image:
		# Always replace with line background if available
	
		texture = get_image(line_bg_image)
		print(texture)
		current_bg.texture = texture
		print("balatuba")
	elif not current_bg.texture and chapter_bg_image:
		# Only apply chapter BG if no background has been set yet
		texture = get_image(chapter_bg_image)
		if texture:
			current_bg.texture = texture
			print(chapter_bg_image)
	else:
		# No line_bg → keep the old one
		print("Keeping previous BG:", current_bg.texture)

func get_image(image_url) -> Texture2D:
	if typeof(image_url) == TYPE_STRING:
		if image_url.begins_with("res://"):
			return load(image_url) as Texture2D
		else:
			# External file (e.g. from user storage)
			var img := Image.load_from_file(image_url)
			if img:
				return ImageTexture.create_from_image(img)
	elif image_url is Texture2D:
		return image_url
	
	push_error("Unsupported image_url: " + str(image_url))
	return null


func _on_next_button_down() -> void:
	if index < len(Globals.chapter_resource.result.scenes) - 1:
		dialog_ui.set_index()
		index = dialog_ui.get_current_index()
		set_bg()
		auto_place_character()
	else:
		levels_container._on_level_button_toggled(true)
		animation_player.play("pop_up")
		#Globals.touch_btn.hide()
