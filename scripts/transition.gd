extends Control
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var panel = $CanvasLayer/Panel
@onready var container = $CanvasLayer/CenterContainer
@onready var image_loader = ImageLoader.new()
@onready var chapter_number_label = $CanvasLayer/ChapterTransition/ChapterNumber
@onready var chapter_title_label = $CanvasLayer/ChapterTransition/ChapterTitle
func _ready() -> void:
	add_child(image_loader)
	
func change_scene(target: String, no_http_request: bool = true, type: String = 'dissolve')-> void:
	if type == "move_left":
		transition_move_left(target, no_http_request)
	else:
		transition_dissolve(target, no_http_request)

#transitions
func transition_dissolve(target: String, no_http_request = true) -> void:
	animation_player.play('dissolve')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	if no_http_request:
		animation_player.play_backwards("dissolve")
		await animation_player.animation_finished

func transition_move_left(target: String, no_http_request = true) -> void:
	animation_player.play('move_left')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	if no_http_request:
		animation_player.play_backwards("move_left")
		await animation_player.animation_finished

#play backwards. use when you want to wait something before finishing the transition
func play_backward(animation):
	animation_player.play_backwards(animation)
	await animation_player.animation_finished

#the transition animation the used when starting a level
func transition_chapter(target: String) -> void:
	animation_player.play('chapter_transition')
	await animation_player.animation_finished
	if Globals.chapter_resource.result.scenes:
		set_character_images()
	else:
		print("No scenes")
#set the characters image resource while in transition. It is used in transition_chapter function
func set_character_images() -> void:
	var scenes: Array = Globals.chapter_resource.result.scenes
	var scenes_with_texture: Array = []
	if scenes:
		for scene in scenes:
			var image_url = scene.speaker.image
			var current_scene = scene

			if image_url == "":
				scenes_with_texture.append(current_scene)
			else:
				var texture: ImageTexture = await image_loader.load_image_async(image_url)
				if texture:
					current_scene.speaker.image = texture
				else:
					print("Failed to load image.")
				scenes_with_texture.append(current_scene)

		Globals.chapter_resource.result.scenes = scenes_with_texture
		print("✅ All scenes processed!")
		get_tree().change_scene_to_file("res://scenes/main/story.tscn")
		play_backward("chapter_transition")
	else:
		print("No scenes")

func set_chapter_info(number: int, title: String):
	chapter_number_label.text = "KABANATA %d" % number
	chapter_title_label.text = title
	
