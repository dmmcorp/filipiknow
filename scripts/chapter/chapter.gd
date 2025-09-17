extends Control

@onready var anim_player = $AnimationPlayer
@onready var default_bg = $BackgroundImage as TextureRect
@onready var chapter_number = $CenterContainer/TextureRect/MarginContainer/VBoxContainer/ChapterNumber
@onready var chapter_title = $CenterContainer/TextureRect/MarginContainer/VBoxContainer/ChapterTitle
@onready var close_button = $CenterContainer/TextureRect/CloseButton

var chapter_resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chapter_resource = Globals.chapter_resource.result.novel_metadata
	if chapter_resource:
		set_default_bg()
		set_chapter_info()
		anim_player.play("pop_up")
	
func set_default_bg():
	#it must be a type of Image Textture
	var image = chapter_resource.bg_image
	if image:
		default_bg = image

func set_chapter_info():
	chapter_number.text = "Kabanata " + str(int(chapter_resource.chapter))
	chapter_title.text = str(chapter_resource.chapter_title)
	print(chapter_number.text)


func _on_close_button_button_down() -> void:
	print("pressed")
	anim_player.play_backwards("pop_up")
	await anim_player.animation_finished
	SceneTransition.transition_dissolve("res://scenes/main/novel_select.tscn")


func _on_continue_button_button_down() -> void:
	print("pressed continue")
	anim_player.play_backwards("pop_up")
	await anim_player.animation_finished
	SceneTransition.transition_dissolve("res://scenes/main/story.tscn")
