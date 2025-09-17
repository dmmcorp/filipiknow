extends GridContainer

@onready var control_node = $"../../MarginContainer/Control"
@onready var letter_scene = preload("res://scenes/ui/question/letter_container.tscn")
@onready var submit_button = $"../../CenterContainer/SubmitButton"
@onready var http_request = submit_button.get_node("HTTPRequest")
@onready var submit_btn = $"../../CenterContainer/SubmitButton"
@onready var next_button_container = $"../../CenterContainer/HBoxContainer"
@onready var question_containmer = $"../../../../.."
@onready var http_get_resources = $HTTPRequest
@onready var question_container_anim = $"../../../../AnimationPlayer"

signal progress_updated(new_progress)
signal answer_submitted(success: bool, points: float)

var correct_answer: Array = []
var empty_slots: Array = []
var slot_buttons: Array = []
var slot_sources: Dictionary = {}
var points: float = Globals.selected_level.points

func _ready() -> void:
	control_node.answer_ready.connect(_on_answer_ready)
	control_node.letter_clicked.connect(_on_letter_clicked)
	submit_button.pressed.connect(_on_submit_pressed)
	http_request.request_completed.connect(_on_http_request_completed) #connect signal

func _on_answer_ready(answer: Array) -> void:
	correct_answer = answer
	columns = correct_answer.size()
	_populate_letters()

func _populate_letters() -> void:
	for child in get_children():
		child.queue_free()
	empty_slots.clear()
	slot_buttons.clear()
	slot_sources.clear()

	for i in range(correct_answer.size()):
		var letter_instance = letter_scene.instantiate()
		letter_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		letter_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(letter_instance)

		var lbl = letter_instance.get_node("Label")
		lbl.text = ""

		letter_instance.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_slot_clicked(i)
		)

		slot_buttons.append(lbl)
		empty_slots.append(i)

func _on_letter_clicked(letter: String, btn: Button) -> void:
	if empty_slots.is_empty():
		return

	var slot_index = empty_slots.pop_front()
	var lbl = slot_buttons[slot_index]
	lbl.text = letter

	btn.disabled = true
	btn.modulate = control_node.selected_color
	slot_sources[slot_index] = btn

func _on_slot_clicked(slot_index: int) -> void:
	var lbl = slot_buttons[slot_index]
	if lbl.text == "":
		return

	lbl.text = ""
	empty_slots.push_front(slot_index)

	if slot_sources.has(slot_index):
		var btn = slot_sources[slot_index]
		btn.disabled = false
		btn.modulate = control_node.normal_color
		slot_sources.erase(slot_index)

func _on_submit_pressed() -> void:
	# Collect the letters from slot_buttons
	var user_answer: Array = []
	for lbl in slot_buttons:
		if lbl.text != "":
			user_answer.append(lbl.text)

	# Convert array to string and lowercase it
	var answer_str: String = "".join(user_answer).to_lower()
	var correct_ans_str: String = "".join(correct_answer).to_lower()
	
	var data
	var progressId = Globals.progress_data.progress._id
	var gameId = Globals.selected_level._id
	var time_spent = 0 # TODO: measure actual time spent
	var url = Globals.url + "recordStudentScore"
	var headers = ["Content-Type: application/json"]
	
	var is_correct = correct_ans_str == answer_str
	if is_correct == true:
		data = {
			"progressId": progressId,
			"score": points,
			"time_spent": time_spent,
			"gameId": gameId
		}
		print(data)
		submit_btn.text = "Correct!"
		var body = JSON.stringify(data)
		print("Sending request:", data)
		http_request.request(url, headers, HTTPClient.METHOD_POST, body)
		submit_button.disabled = true
		submit_button.text = "Submitting..."
	
	else:
		data = {
			"progressId": progressId,
			"score": 0,
			"time_spent": time_spent,
			"gameId": gameId
		}
		print(data)
		print("❌ Wrong. Not adding points")
		emit_signal("answer_submitted", false, 0)
		
	print("labas:", data)
# ✅ Handle server response
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	print("HTTP Result:", result, "Status:", response_code, "Body:", text)

	if response_code == 200:
		var json = JSON.parse_string(text)
		if typeof(json) == TYPE_DICTIONARY and json.has("success") and json["success"]:
			print("Score recorded successfully:",)
			print("Display score and proceed to next level ui",)
			print("Correct! Adding: ", points, "points")
			get_level_resources(json.data.nextLevel)
			get_student_progress()
			emit_signal("answer_submitted", true, points)
		else:
			print("Server responded but with error:", json)
			print("Score recorded successfully:",)
			print("Display score and proceed to next level ui",)
			emit_signal("answer_submitted", false, 0)
		submit_button.text = "Submitted"
	else:
		print("HTTP error code:", response_code, "Message:", text)
		submit_button.text = "Retry"
		emit_signal("answer_submitted", false, 0)

func get_level_resources(selected_level: int):
	if Globals.chapter_resource.result.has("levels"):
		for game in Globals.chapter_resource.result["levels"]:
			if int(game.level) == float(selected_level):
				Globals.selected_level = game
				print(Globals.selected_level)

func instantiate_question_scene():
	var questions_scene = preload("res://scenes/main/question.tscn")
	var questions_instance = questions_scene.instantiate()
	get_parent().add_child(questions_instance)
	
func get_student_progress() -> void:
	var data = Globals.load_auth_data()
	var headers = [
		"Content-Type: application/json"
	]
	var url = Globals.url + "getStudentInfoAndProgress"
	if data.has("user_id"):
		var userId = { "userId": data.user_id }
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
		print(json.progress)
		print("Fetch in question:",json.progress)
		Globals.access_grid_buttons()
	else:
		print("failed to fetch progresss data.")
