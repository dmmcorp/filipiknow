extends Control
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var panel = $CanvasLayer/Panel
@onready var container = $CanvasLayer/CenterContainer
@onready var image_loader = ImageLoader.new()
@onready var progress_bar = $CanvasLayer/ChapterTransition/ProgressBar
@onready var percent_label = $CanvasLayer/ChapterTransition/Percentage
@onready var chapter_title_label = $CanvasLayer/ChapterTransition/ChapterTitle
@onready var progress_label = $CanvasLayer/AssessmentTransition/ProgressLabel
@onready var loading_bar = $CanvasLayer/AssessmentTransition/LoadingBar
@onready var assessment_transition_texture = $CanvasLayer/AssessmentTransition

var visual_progress := 0.0
var finished_flag := false

func _ready() -> void:
	Globals.connect("load_progress", Callable(self, "_on_load_progress"))
	Globals.connect("load_finished", Callable(self, "_on_load_finished"))
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
			var texture: ImageTexture = await CacheMngr.get_cached_image(image_url)
			if texture:
				current_scene.speaker.image = texture
			else:
				print("❌ Failed to load speaker image:", image_url)

		# --- Always handle background image (even if no speaker) ---
		if scene_bg_image_url != "":
			var scene_bg_texture: ImageTexture = await CacheMngr.get_cached_image(scene_bg_image_url)
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

	# ✅ Save processed scenes
	Globals.chapter_resource.result.scenes = scenes_with_texture
	print("✅ All scenes processed (cached)!")


func set_bg_images() -> void:
	var chapter_data = Globals.chapter_resource.result.novel_metadata
	if chapter_data.has("bg_image"):
		var url: String = chapter_data.bg_image
		if url != "" and url != null:
			var texture = await CacheMngr.get_cached_image(url)
			if texture:
				chapter_data.bg_image = texture
			else:
				print("❌ Failed to load background image from:", url)

func set_chapter_info(number: int, title: String):
	#chapter_number_label.text = "KABANATA %d" % number
	chapter_title_label.text = "Loading.."
	
	
func assessment_transitioon(animation:String = "In"):
	if animation == "In":
		assessment_transition_texture.visible = true
		animation_player.play("AssessmentTransition")
		await animation_player.animation_finished
	else:
		animation_player.play_backwards("AssessmentTransition")
		await animation_player.animation_finished
		assessment_transition_texture.visible = false

func _on_load_progress(loaded_increment := 1):
	# Add a small increment to progress each call
	if finished_flag:
		return
	
	# Increase visual progress by a fraction per call
	visual_progress += 0.01 * loaded_increment
	if visual_progress > 0.7:	# cap at 70% before finished
		visual_progress = 0.7

	# Update UI
	loading_bar.value = visual_progress * 100.0
	progress_label.text = "%d%%" % int(loading_bar.value)

	await get_tree().process_frame
	
func mark_loading_finished():
	if finished_flag:
		return
	finished_flag = true

	while visual_progress < 1.0:
		visual_progress += 0.02	# adjust speed
		if visual_progress > 1.0:
			visual_progress = 1.0

		loading_bar.value = visual_progress * 100.0
		print(loading_bar.value)
		progress_label.text = "%d%%  (Done)" % int(loading_bar.value)
		await get_tree().create_timer(0.02).timeout
		
func _on_load_finished(status):
		# Path to your Assessment scene
	var assessment_scene_path = "res://scenes/main/assessment.tscn"
	var assessment_scene = load(assessment_scene_path)
	if not assessment_scene:
		push_error("❌ Failed to load assessment scene at path: " + assessment_scene_path)
		return
	if status == "finished":
		mark_loading_finished()
		print("Loading completed!")
		var assessment_instance = assessment_scene.instantiate()
		# Optionally, pass your selected assessments to the new scene
		if Globals.assessments is Array:
			#load the images first before seeting up the assessments
			get_tree().current_scene.add_child(assessment_instance)
			await get_tree().process_frame
			
			if assessment_instance.has_method("setup_assessments"):
				assessment_instance.setup_assessments(Globals.assessments)
			else:
				push_warning("⚠️ setup_assessments() not found in assessment scene.")
		
		assessment_transitioon("Out")
		SceneTransition.transition_dissolve(assessment_scene_path, false)
		visual_progress = 0.0
		finished_flag = false
