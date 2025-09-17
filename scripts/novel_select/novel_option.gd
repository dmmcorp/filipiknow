class_name NovelOptions
extends Control

@onready var http_request = $HTTPRequest
@onready var http_get_resources = $GETChapterResources
@onready var novel_title_label = $TextureRect/MarginContainer/HBoxContainer/Tabs/Noli/Label
@onready var noli_tab = $TextureRect/MarginContainer/HBoxContainer/Tabs/Noli
@onready var elfili_tab = $TextureRect/MarginContainer/HBoxContainer/Tabs/Elfili
@onready var noli_lock = $TextureRect/MarginContainer/HBoxContainer/Tabs/Noli/TextureRect
@onready var Elfili_lock = $TextureRect/MarginContainer/HBoxContainer/Tabs/Elfili/TextureRect
@onready var chapter_list = $TextureRect/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/MarginContainer/ScrollContainer/ChaptersContainer
@onready var get_student_progress_http = $TextureRect/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/MarginContainer/ScrollContainer/ChaptersContainer/StudentProgress
@onready var points = $PanelContainer2/HBoxContainer/Points

var selected_tab = "1"
var original_scale = Vector2.ONE
var hover_scale = Vector2(1.05, 1.05)
var dark_brown = Color(0.88,0.484,0.278)
var brown = Color(1,1,1)
var selected: Dictionary
var progress_fetched: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request.request_completed.connect(_on_http_request_request_completed)
	http_get_resources.request_completed.connect(_on_get_chapter_resources_request_completed)
	await get_student_progress()
	load_data()
	#print(Globals.progress_data)
func get_student_progress() -> void:
	var headers = [
		"Content-Type: application/json"
	]
	var url = Globals.url + "getStudentInfoAndProgress"
	if Globals.user_id:
		var userId = { "userId": Globals.user_id }
		var json = JSON.stringify(userId)
		http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)
	if json and json.get("success", false):
		Globals.save(json)
		Globals.progress_data = {
			"student": json.student,
			"progress": json.progress
		}
		points.text = str(int(json.progress.total_points))
		load_data()
		SceneTransition.play_backward("dissolve")

		# ✅ Mark fetch as finished
		progress_fetched = true
	else:
		print("❌ Auto-login failed. Show login screen.")
		SceneTransition.change_scene("res://scenes/main/login.tscn")

func load_data()-> void:
	if Globals.progress_data:
		_grade_checker()
		_set_selected_tab_color()
		_create_chapters()

func _grade_checker()-> void:
	if Globals.progress_data.student.gradeLevel == "Grade 9":
		Elfili_lock.visible = true
		noli_lock.visible = false
		noli_tab.disabled = false
		elfili_tab.disabled = true
		selected_tab = "1"
		novel_title_label.text = "Noli me tangere"
		selected["novel"] = "Noli me tangere"
	else:
		Elfili_lock.visible = false
		noli_lock.visible = true
		noli_tab.disabled = true
		elfili_tab.disabled = false
		selected_tab = "2"
		novel_title_label.text = "El Filibusterismo"
		selected["novel"] = "El Filibusterismo"

func _set_selected_tab_color()-> void:
	if selected_tab == "1":
		noli_tab.self_modulate = dark_brown
		elfili_tab.self_modulate = brown
	else:
		noli_tab.self_modulate = brown
		elfili_tab.self_modulate = dark_brown

func _on_noli_button_down() -> void:
	novel_title_label.text = "Noli me tangere"
	selected_tab = "1"
	selected['novel'] = "Noli me tangere"
	_set_selected_tab_color()
func _on_elfili_button_down() -> void:
	novel_title_label.text = "El Filibusteresmo"
	selected_tab = "2"
	selected['novel'] = "El Filibusteresmo"
	_set_selected_tab_color()
	
func _on_noli_mouse_entered() -> void:
	noli_tab.scale = hover_scale

func _on_noli_mouse_exited() -> void:
	noli_tab.scale = original_scale

func _on_elfili_mouse_entered() -> void:
	elfili_tab.scale = hover_scale

func _on_elfili_mouse_exited() -> void:
	elfili_tab.scale = original_scale

func _create_chapters()-> void:
	var chapters_count = 0
	if Globals.progress_data.student.gradeLevel.to_lower() == "grade 9":
		chapters_count = 65
	else:
		chapters_count = 40
	for i in range(1, chapters_count):
		var btn = Button.new()
		btn.disabled = true
		_set_chapters_theme(btn, i, "chapters")
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		if i > Globals.progress_data.progress.current_chapter:
			btn.disabled = true
			btn.icon = load("res://assets/images/lock-icon.png")
		else:
			btn.disabled = false
			btn.icon = load("res://assets/images/transparent-icon-lock.png")
			
		
func _set_chapters_theme(btn:Button, i, type)-> void:
	if type == "chapters":
		btn.text = "KABANATA %d" % i
	else:
		btn.text = "Level %d" % i
	btn.theme = load("res://theme/button_theme.tres")
	btn.theme_type_variation = "chapter"
	btn.size_flags_horizontal = Control.SIZE_FILL
	btn.connect("pressed", Callable(self, "_on_chapter_pressed").bind(btn,i))
	chapter_list.add_child(btn)

func _on_chapter_pressed(btn, num: int) -> void:
	btn.disabled = true
	var tween := create_tween()
	if btn.text == "KABANATA %d" % num:
		selected["chapter"] = num

	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.1)

	# ✅ Reset before fetch
	progress_fetched = false
	Globals.selected_chapter_level = selected
	refetch_progress()
	# Wait until fetch is done
	await self.progress_fetched

	#print("pressed")
	get_chapter_resources()
	btn.disabled = false
	
func refetch_progress() -> void:
	var headers = [
		"Content-Type: application/json"
	]
	var url = Globals.url + "getStudentInfoAndProgress"
	if Globals.user_id:
		var userId = { "userId": Globals.user_id }
		var json = JSON.stringify(userId)
		print("Pasok naman")
		get_student_progress_http.request(url, headers, HTTPClient.METHOD_POST, json)

func _on_student_progress_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)
	if json and json.get("success", false):
		Globals.save(json)
		Globals.progress_data = {
			"student": json.student,
			"progress": json.progress
		}
		points.text = str(int(json.progress.total_points))
	else:
		print("Can't refetch in While in chapter loading.")
func _on_back_to_chapters_button_down() -> void:
	# Clear all existing buttons
	for button in chapter_list.get_children():
		chapter_list.remove_child(button)
		button.queue_free()
	# Recreate chapter buttons
	_create_chapters()


func get_chapter_resources():
	var headers = [
		"Content-Type: application/json"
	]
	if selected.has("novel") and selected.has("chapter"):
		var data = {
			"novel": selected["novel"],
			"chapter": selected["chapter"],
			"teacherId": Globals.progress_data.student.teacher["teacherId"],
			"sectionId": Globals.progress_data.student.teacher["sectionId"]
		}
		var url = Globals.url + "getChapterDialogues"
		var json_data = JSON.stringify(data)
		http_get_resources.request(url, headers, HTTPClient.METHOD_POST, json_data)

func _on_get_chapter_resources_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)
	if not json:
		print("Failed to parse JSON!")
		return
	if json and json.get("success", false):
		Globals.chapter_resource = json
		var story_scene = load("res://scenes/main/story.tscn")
		var chapter_title = Globals.chapter_resource.result.novel_metadata.chapter_title
		var chapter_number = Globals.chapter_resource.result.novel_metadata.chapter
		SceneTransition.set_chapter_info(chapter_number, chapter_title)
		Globals.access_grid_buttons()
		SceneTransition.transition_chapter("res://scenes/main/chapter.tscn")
	else:
		print(json)
		
