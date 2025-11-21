extends Node

#uncomment this if using dev db
var url := "https://tangible-chicken-583.convex.site/"

#uncomment this if using production db
#var url := "https://charming-marten-156.convex.site/"

var is_logged_in := false
var user_id
var user_email := ""
var user_firstname := ""
var user_lastname := ""

#variables for story scene
var selected_chapter_level
var input_enabled = true
var progress_data
var chapter_resource
var touch_btn
var levels_btn
var selected_level
var assessments
var progress
var level_grid_container: GridContainer
var levels_node  # <- reference to the Levels.gd node
var touch_button: TouchScreenButton

#signals for loading the assessment transition
signal load_progress(progress: float, loaded: int, total: int)
signal load_finished

func auth_guard(http_request: HTTPRequest)->void:
	SceneTransition.change_scene("res://scenes/main/login.tscn")
		
func load_auth_data() -> Dictionary:
	if FileAccess.file_exists("user://auth_data.json"):
		var file = FileAccess.open("user://auth_data.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data and data.has("token"):
			return data
	return {}
	
func verify_token(token: String, request):
	var headers = [
		"Authorization: Bearer " + token,
		"Content-Type: application/json"
	]
	var path = Globals.url + "api/auth/me"
	request.request(path, headers, HTTPClient.METHOD_POST, "")
	#the http result is in the main_menu.gd
	
func save(data, path = "user://auth_data.json"):
	var jsonString = JSON.stringify(data)
	var jsonFile = FileAccess.open(path, FileAccess.WRITE)
	jsonFile.store_line(jsonString)	
	jsonFile.close()

func _emit_level_pressed(index: int) -> void:
	if Globals.levels_node:
		Globals.levels_node.emit_signal("level_pressed", index)
	
func access_grid_buttons():
	progress = Globals.progress_data
	print("reaccess the grid item")
	print("This is the progress:", progress)

	# ✅ Get levels safely
	var levels: Array = []
	if Globals.chapter_resource.result.levels:
		levels = Globals.chapter_resource.result.levels
	
	if level_grid_container:
		for child in level_grid_container.get_children():
			var index = level_grid_container.get_children().find(child)

			if child is TextureButton:
				# Ensure signal is connected
				if not child.is_connected("button_down", Callable(self, "_on_level_button_button_down").bind(index)):
					child.connect("button_down", Callable(self, "_on_level_button_button_down").bind(index))

				#Check if level exists
				var level_exists = index < levels.size()
				var current_level = int(progress.progress.progress.current_level)

				if not level_exists:
					# No such level mark N/A
					child.disabled = true
					for subchild in child.get_children():
						if subchild is TextureRect:
							subchild.visible = false
						if subchild is Label:
							subchild.text = "N/A"
							subchild.visible = true
					continue

				#Match levels correctly (index + 1)
				var level_number = index + 1

				if level_number < current_level:
					# Past levels → Finished → Disabled
					child.disabled = true
					for subchild in child.get_children():
						if subchild is Label:
							subchild.text = "✔"
							subchild.visible = true
						if subchild is TextureRect:
							subchild.visible = false

				elif level_number == current_level:
					# Current level → Enabled
					child.disabled = false
					for subchild in child.get_children():
						if subchild is Label:
							subchild.visible = true
						if subchild is TextureRect:
							subchild.visible = false

				else:
					# Future levels → Locked
					child.disabled = true
					for subchild in child.get_children():
						if subchild is Label:
							subchild.visible = false

func _on_level_button_button_down(index: int) -> void:
	var level = index + 1
	print("index:", index)
	get_level_resources(level)

	if levels_node:  # make sure Levels.gd node is registered
		# Your animation + toggle reset logic here
		
		levels_node.anim_player.play_backwards("show_levels")
		await levels_node.anim_player.animation_finished

		levels_node.levels_container.visible = false
		if level == 10:
			_load_assessment_scene()
		else:
			levels_node.instantiate_question_scene()
	Globals.input_enabled = false

func _load_assessment_scene():
	# Path to your Assessment scene
	var assessment_scene_path = "res://scenes/main/assessment.tscn"
	var assessment_scene = load(assessment_scene_path)

	if not assessment_scene:
		push_error("❌ Failed to load assessment scene at path: " + assessment_scene_path)
		return

	# Instantiate the scene
	var assessment_instance = assessment_scene.instantiate()
	
	SceneTransition.assessment_transitioon("In")

	# Optionally, pass your selected assessments to the new scene
	if Globals.assessments is Array:
		#load the images first before seeting up the assessments
		await load_assessment_textures_parallel()
		
		if assessment_instance.has_method("setup_assessments"):
			assessment_instance.setup_assessments(Globals.assessments)
		else:
			push_warning("⚠️ setup_assessments() not found in assessment scene.")
	
	# Transition effect
	SceneTransition.transition_dissolve(assessment_scene_path, false)
	
	print("✅ Assessment scene instantiated and transitioning!")

func get_level_resources(selected_level: int):

	if Globals.chapter_resource.result.has("levels"):
		for game in Globals.chapter_resource.result["levels"]:
			if int(game.level) == float(selected_level):
				if selected_level == 10:
					var assessments: Array = []
					assessments.append(game)
					Globals.assessments = assessments
					print(Globals.selected_level)
				else:
					Globals.selected_level = game

#Returns the ImageTexture or the url itself if something went wrong.
func load_texture_from_url(url: String) -> Variant:
	var req = HTTPRequest.new()
	add_child(req)
	var finished = false
	var result_texture: Texture2D = null

	var http_err := req.request(url)
	if http_err != OK:
		push_error("Failed to start HTTP request: %s" % http_err)
		return url
		var result = await req.request_completed
	
	var result = await req.request_completed
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]

	if response_code == 200:
		var img = Image.new()
		var err := img.load_png_from_buffer(response_body)
		if err != OK:
			push_warning("⚠️ Failed to load image from buffer: %s" % err)
			return url
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		return tex
	else:
		push_warning("⚠️ Image HTTP error: %s" % response_code)
	return url

# Load all textures in parallel for all assessments
func load_assessment_textures_parallel():
	var total_images := 0
	var loaded_images := 0
	var tasks := []
	for assessment in Globals.assessments:
		if assessment.has("fourPicsOneWord") and assessment.fourPicsOneWord.images.size() > 0:
			var tex_promises := []
			for url in assessment.fourPicsOneWord.images:
				tex_promises.append(await load_texture_from_url(url))
			tasks.append({ "target": assessment.fourPicsOneWord, "key": "images", "promises": tex_promises })
			
		# Multiple Choice
		if assessment.has("multipleChoice") and assessment.multipleChoice.image != "":
			tasks.append({
				"target": assessment.multipleChoice,
				"key": "image",
				"promises": [await load_texture_from_url(assessment.multipleChoice.image)]
			})

		# Jigsaw Puzzle
		if assessment.has("jigsawPuzzle") and assessment.jigsawPuzzle.image != "":
			tasks.append({
				"target": assessment.jigsawPuzzle,
				"key": "image",
				"promises": [await load_texture_from_url(assessment.jigsawPuzzle.image)]
			})
		# Who Said It
		if assessment.has("whoSaidIt") and assessment.whoSaidIt.options.size() > 0:
			for i in range(assessment.whoSaidIt.options.size()):
				var opt = assessment.whoSaidIt.options[i]
				if opt.image:
					tasks.append({
						"target": assessment.whoSaidIt.options,
						"key": str(i) + ".image",
						"promises": [await load_texture_from_url(opt.image)]
					})
	# Await all tasks in parallel
	for task in tasks:
		var results := []
		for promise in task.promises:
			results.append(await promise)
			# Update progress
			loaded_images += 1
			var progress := float(loaded_images) / float(total_images)

			emit_signal("load_progress", progress, loaded_images, total_images)

			await get_tree().process_frame
		 # Handle nested key like "0.images"
		if typeof(task.key) == TYPE_STRING:
			var parts = task.key.split(".")
			if parts.size() == 2:
				var idx = int(parts[0])
				var subkey = parts[1]
				task.target[idx][subkey] = results if results.size() > 1 else results[0]
			else:
				task.target[task.key] = results if results.size() > 1 else results[0]
		else:
			task.target[task.key] = results if results.size() > 1 else results[0]
	print("✅ All assessment images loaded in parallel and replaced with textures")
	emit_signal("load_finished")
