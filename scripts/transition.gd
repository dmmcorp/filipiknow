extends Control
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var panel = $CanvasLayer/Panel
@onready var container = $CanvasLayer/CenterContainer
@onready var image_loader = ImageLoader.new()
@onready var progress_bar = $CanvasLayer/ChapterTransition/ProgressBar
@onready var percent_label = $CanvasLayer/ChapterTransition/Percentage
@onready var chapter_title_label = $CanvasLayer/ChapterTransition/ChapterTitle


func _ready() -> void:
	add_child(image_loader)

func change_scene(target: String, no_http_request: bool = true, type: String = 'dissolve')-> void:
	if type == "move_left":
		panel.visible = true
		container.visible = true
		transition_move_left(target, no_http_request)
	else:
		transition_dissolve(target, no_http_request)

#transitions
func transition_dissolve(target: String, no_http_request = true) -> void:
	animation_player.play('dissolve')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	get_tree().reload_current_scene()
	if no_http_request:
		animation_player.play_backwards("dissolve")
		await animation_player.animation_finished

func transition_move_left(target: String, no_http_request = true) -> void:
	animation_player.play('move_left')
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	get_tree().reload_current_scene()
	if no_http_request:
		animation_player.play_backwards("move_left")
		await animation_player.animation_finished

#play backwards. use when you want to wait something before finishing the transition
func play_backward(animation):
	animation_player.play_backwards(animation)
	await animation_player.animation_finished
	# 🔄 Reset progress after the backward animation ends
	progress_bar.value = 0
	percent_label.text = "0%"
	print("🔄 Progress reset after backward animation")

#the transition animation the used when starting a level
func transition_chapter(target: String) -> void:
	animation_player.play('chapter_transition')
	await animation_player.animation_finished
	var resource_to_load
	var loaded_count := 0
	progress_bar.value = loaded_count

	if Globals.chapter_resource.result and Globals.chapter_resource.result.scenes: 
		var scene_size = Globals.chapter_resource.result.scenes.size()
		progress_bar.min_value = 0
		progress_bar.max_value = scene_size
		progress_bar.value = 0
		percent_label.text = "0%"
		resource_to_load = Globals.chapter_resource.result.scenes
		set_bg_images()
		await set_character_images(resource_to_load, loaded_count)
	
		get_tree().change_scene_to_file("res://scenes/main/chapter.tscn")
		get_tree().reload_current_scene()
		play_backward("chapter_transition")
		loaded_count = 0
	else:
		print("No scenes")
		loaded_count = 0


#set the characters image resource while in transition. It is used in transition_chapter function
func set_character_images(resource_to_load: Array, loaded_count: int) -> void:
	loaded_count = 0
	
	var scenes: Array = Globals.chapter_resource.result.scenes
	var scenes_with_texture: Array = []

	if not scenes:
		print("⚠️ No scenes")
		return

	for index in range(scenes.size()):
		var current_scene = scenes[index]
		var scene_bg_image_url: String = current_scene.get("scene_bg_image", "")
		var image_url: String = ""

		# ✅ Check if speaker exists safely
		if current_scene.has("speaker") and current_scene.speaker:
			if current_scene.speaker.has("image"):
				image_url = current_scene.speaker.image

		# --- Handle speaker image (if any) ---
		if image_url != "":
			var texture: ImageTexture = await image_loader.load_image_async(image_url)
			if texture:
				current_scene.speaker.image = texture
			else:
				print("❌ Failed to load speaker image:", image_url)

		# --- Always handle background image (even if no speaker) ---
		if scene_bg_image_url != "":
			var scene_bg_texture: ImageTexture = await image_loader.load_image_async(scene_bg_image_url)
			if scene_bg_texture:
				current_scene.scene_bg_image = scene_bg_texture
			else:
				print("❌ Failed to load background image:", scene_bg_image_url)
		else:
			print("ℹ️ No scene_bg_image set for this scene")

		# ✅ Always push scene back into list
		scenes_with_texture.append(current_scene)

		# ✅ Update progress only after finishing this scene
		var path = resource_to_load[index]
		loaded_count += 1
		progress_bar.value = loaded_count

		var percent = int(float(loaded_count) / float(resource_to_load.size()) * 100.0)
		percent_label.text = str(percent) + "%"
		print("Loaded:", path, "Progress:", percent, "%")

	# ✅ Save processed scenes
	Globals.chapter_resource.result.scenes = scenes_with_texture
	print("✅ All scenes processed!")


func set_bg_images() -> void:
	var chapter_data = Globals.chapter_resource.result.novel_metadata
	if chapter_data.has('bg_image'):
		if chapter_data.bg_image != "" or chapter_data.bg_image != null:
			var texture: ImageTexture = await image_loader.load_image_async(chapter_data.bg_image)
			if texture:
				chapter_data.bg_image = texture
			else:
				print("Failed to load image.")
		
func set_chapter_info(number: int, title: String):
	#chapter_number_label.text = "KABANATA %d" % number
	chapter_title_label.text = "Loading.."
	
