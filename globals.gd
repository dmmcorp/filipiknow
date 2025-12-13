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
var assessment_answer
var assessment_submit_btn
#signals for loading the assessment transition
signal load_progress(progress: float, loaded: int, total: int)
signal load_finished(status: String)

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
			emit_signal("load_finished", "finished")
		else:
			levels_node.instantiate_question_scene()
	Globals.input_enabled = false

func _load_assessment_scene():
	SceneTransition.assessment_transitioon("In")
	print("✅ Assessment scene instantiated and transitioning!")

func get_level_resources(selected_level: int):
	if Globals.chapter_resource.result.has("levels"):
		var assessments: Array = []
		for game in Globals.chapter_resource.result["levels"]:
			if int(game.level) == float(selected_level):
				if selected_level == 10:
					assessments.append(game)
				else:
					Globals.selected_level = game
		Globals.assessments = assessments
	print("This is the stored assessments:",Globals.assessments)

#Returns the ImageTexture or the url itself if something went wrong.
func load_texture_from_url(url: String) -> Variant:
	var req := HTTPRequest.new()
	add_child(req)

	var http_err := req.request(url)
	if http_err != OK:
		push_error("Failed to start HTTP request: %s" % http_err)
		return url

	var result = await req.request_completed
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]

	if response_code == 200:
		var img := Image.new()
		var err := img.load_png_from_buffer(response_body)

		if err != OK:
			push_warning("⚠️ Failed to load image from buffer: %s" % err)
			return url

		var tex := ImageTexture.create_from_image(img)
		return tex

	push_warning("⚠️ Image HTTP error: %s" % response_code)
	return url

func load_assessment_textures():
	print("Loading assessment resources…")
	emit_signal("load_finished", "loading")
	await get_level_resources(10)
	for assessment in Globals.assessments:
		# Four Pics One Word
		if assessment.has("fourPicsOneWord"):
			var new_images := []
			for url in assessment.fourPicsOneWord.images:
				var tex = await load_texture_from_url(url)
				new_images.append(tex)
				emit_signal("load_progress")
				print("+1")
				await get_tree().process_frame
			assessment.fourPicsOneWord.images = new_images
			
		# Multiple Choice
		if assessment.has("multipleChoice"):
			assessment.multipleChoice.image = await load_texture_from_url(assessment.multipleChoice.image)
			emit_signal("load_progress")
		# Jigsaw Puzzle
		if assessment.has("jigsawPuzzle"):
			assessment.jigsawPuzzle.image = await load_texture_from_url(assessment.jigsawPuzzle.image)
			emit_signal("load_progress")
		# Who Said It
		if assessment.has("whoSaidIt"):
			for i in range(assessment.whoSaidIt.options.size()):
				var opt = assessment.whoSaidIt.options[i]
				if opt.image:
					assessment.whoSaidIt.options[i].image = await load_texture_from_url(opt.image)
					emit_signal("load_progress")
		# Identification
		# (No image to load here unless you have optional images)
	
	print("✅ All assessment images loaded and replaced with textures")
