class_name NovelOptions
extends Control

@onready var http_request = $HTTPRequest
@onready var http_get_resources = $GETLevelResources
@onready var novel_title_label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/NovelTitleLabel
@onready var noli_tab = $PanelContainer/HBoxContainer/Tabs/Noli
@onready var elfili_tab = $PanelContainer/HBoxContainer/Tabs/Elfili
@onready var noli_lock = $PanelContainer/HBoxContainer/Tabs/Noli/TextureRect
@onready var Elfili_lock = $PanelContainer/HBoxContainer/Tabs/Elfili/TextureRect
@onready var levelLabel = $PanelContainer2/HBoxContainer/LevelLabel
@onready var chapter_list = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/ChaptersContainer
@onready var selected_chapter_label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/HBoxContainer/SelectedChapter
@onready var back_btn = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/HBoxContainer/BackToChapters

var selected_tab = "1"
var original_scale = Vector2.ONE
var hover_scale = Vector2(1.05, 1.05)
var dark_brown = Color(0.88,0.484,0.278)
var brown = Color(1,1,1)
var selected: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_student_progress()
	load_data()

func get_student_progress()->void:
	var data = Globals.load_auth_data()
	var headers = [
		"Content-Type: application/json"
	]
	var url = Globals.url + "getStudentInfoAndProgress"
	if data.has("user_id"):
		var userId = {
			"userId": data.user_id
		}
		var json = JSON.stringify(userId)
		print(json)
		http_request.request(url, headers, HTTPClient.METHOD_POST,json)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)
	if json and json.get("success", false):
		print(json)
		Globals.save(json)
		Globals.progress_data = {
			"student": json.student,
			"progress": json.progress
		}
		load_data()
		SceneTransition.play_backward("dissolve")
	else:
		print("❌ Auto-login failed. Show login screen.")
		SceneTransition.change_scene("res://scenes/main/login.tscn")

func load_data()-> void:
	if Globals.progress_data:
		_grade_checker()
		_set_selected_tab_color()
		_create_chapters()
		_get_chapter_level()

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
	if Globals.progress_data.student.gradeLevel == "grade 9":
		chapters_count = 65
	else:
		chapters_count = 40
	for i in range(1, chapters_count):
		var btn = Button.new()
		btn.disabled = true
		_set_chapters_theme(btn, i, "chapters")
		if i > Globals.progress_data.progress.current_chapter:
			btn.disabled = true
			btn.icon = load("res://assets/images/lock.png")
		else:
			btn.disabled = false

func _create_levels()-> void:
	for i in range(1, 11):
		var btn = Button.new()
		if i > Globals.progress_data.progress.current_level:
			btn.disabled = true
			btn.icon = load("res://assets/images/lock.png")
		_set_chapters_theme(btn, i, "levels")
		
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
	var tween := create_tween()
	if btn.text == "KABANATA %d" % num:
		selected["chapter"] = num
		print("Chapter %d pressed" % num)
	if btn.text == "Level %d" % num:
		on_level_pressed(btn,num)
		print("Level %d pressed" % num)
	
	print(selected)
	#get the current level in the chapter
	_get_chapter_level()
	selected_chapter_label.visible = true
	selected_chapter_label.text = btn.text
	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.1)
	for button in chapter_list.get_children():
		if button is Button:
			button.visible = false
	_create_levels()

func on_level_pressed(btn, level_num: int) -> void:
	var tween := create_tween()
	selected["level"] = level_num
	get_level_resources()
	
func get_level_resources():
	var headers = [
		"Content-Type: application/json"
	]
	if selected.has("novel") and selected.has("chapter") and selected.has("level"):
		var encoded_novel = selected.novel.replace(" ", "%20")
		var full_url = "%sgetDialogue?novel=%s&chapter=%d&level=%d" % [
			Globals.url,
			encoded_novel,
			selected.chapter,
			selected.level
		]
		print(full_url)
		http_get_resources.request(full_url, headers, HTTPClient.METHOD_GET)

func _get_chapter_level()-> void:
	levelLabel.text = str(int(Globals.progress_data.progress.completed))

func _on_back_to_chapters_button_down() -> void:
	# Clear all existing buttons
	for button in chapter_list.get_children():
		chapter_list.remove_child(button)
		button.queue_free()
	# Show chapter label again
	selected_chapter_label.visible = false
	# Recreate chapter buttons
	_create_chapters()


func _on_get_level_resources_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	print("📦 Raw response text:", response_text)
	var json = JSON.parse_string(response_text)
	if not json:
		print("❌ Failed to parse JSON!")
		return
	
	if json and json.get("success", false):
		print(json)
		Globals.level_resource = json
		var story_scene = load("res://scenes/main/story.tscn")
		SceneTransition.change_scene("res://scenes/main/story.tscn")
	else:
		print(json)
