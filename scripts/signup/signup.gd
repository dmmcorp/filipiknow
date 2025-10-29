class_name Signup
extends Control

@onready var login = "res://scenes/main/login.tscn"
@onready var signup_button = $SignupContainer/SignupBtnContainer/Button
@onready var login_button = $SignupContainer/RichTextLabel
@onready var firstname = $SignupContainer/HBoxContainer/VBoxContainer1/HBoxContainer/Firstname
@onready var lastname = $SignupContainer/HBoxContainer/VBoxContainer1/HBoxContainer/Lastname
@onready var password = $SignupContainer/HBoxContainer/VBoxContainer2/Password
@onready var email = $SignupContainer/HBoxContainer/VBoxContainer1/Email
@onready var lrn = $SignupContainer/HBoxContainer/VBoxContainer2/LRN
@onready var error_message = $SignupContainer/ErrorText
@onready var http_request = $SignupContainer/SignupBtnContainer/Button/HTTPRequest
@onready var gradelevel = $SignupContainer/HBoxContainer/VBoxContainer1/GradeLevel/VBoxContainer/Panel/MarginContainer/HBoxContainer/OptionButton
@onready var get_section = $SignupContainer/GetSectionRequest
@onready var section_dropdown = $SignupContainer/HBoxContainer/VBoxContainer2/Section/VBoxContainer/Panel/MarginContainer/HBoxContainer/OptionButton
@onready var auth_http = $SignupContainer/SignupBtnContainer/Button/AuthRequest
var errors = 0
var sections = []
var filtered_sections = sections
var selectedSectionid: String
var selectedGradeLevel: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_connection_signal()
	# Set placeholders of the text input fields
	input_placeholder_setter()
	# Clear any existing items first (optional)
	gradelevel.clear()

	# Add gradelevel options
	var grades = ["Grade 9", "Grade 10"]
	for grade in grades:
		gradelevel.add_item(grade)
	
func input_placeholder_setter() -> void:
	firstname.set_placeholder("First name")
	lastname.set_placeholder("Last name")
	password.set_placeholder("Password")
	password.set_secret_mode(true)
	email.set_placeholder("Email")
	lrn.set_placeholder("Student LRN")
func on_grade_selected(grade: String) -> void:
	#print("Grade selected in Signup script:", grade)
	filtered_sections = []
	selectedSectionid = ""
	if sections:
		for section in sections:
			if section.gradeLevel.to_lower() == grade.to_lower():
				#print(section.gradeLevel)
				filtered_sections.append(section)
				#print("Filtered:", filtered_sections)
	section_dropdown.clear()
	for section in filtered_sections:
		section_dropdown.add_item(section["name"])
func on_section_selected(section: String) -> void:
	for sec in sections:
		if sec.name.to_lower() == section.to_lower(): # or sec["sectionName"] if it's a dictionary
			var section_id = sec._id     # or sec["_id"] if it's a dictionary
		
			selectedSectionid = section_id
func handle_connection_signal() -> void:
	get_all_sections()
	signup_button.button_down.connect(on_signup_pressed)
	$SignupContainer/HBoxContainer/VBoxContainer1/GradeLevel.grade_selected.connect(on_grade_selected)
	$SignupContainer/HBoxContainer/VBoxContainer2/Section.section_selected.connect(on_section_selected)
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	if meta == "login":
		SceneTransition.change_scene(login)

func on_signup_pressed() -> void:
	if selectedSectionid == "":
		for sec in sections:
			if sec.name.to_lower() == section_dropdown.text.to_lower(): # or sec["sectionName"] if it's a dictionary
				var section_id = sec._id     # or sec["_id"] if it's a dictionary
				#print("Found section ID:", section_id)
				selectedSectionid = section_id

		var section = $SignupContainer/HBoxContainer/VBoxContainer2/Section
	var data := {
		"fname": firstname.get_value(),
		"lname": lastname.get_value(),
		"email": email.get_value(),
		"password": password.get_value(),
		"gradeLevel": gradelevel.get_item_text(gradelevel.selected),
		"section": selectedSectionid,
	}
	#print(data)
	if validate_inputs() == true:
		send_request(data)
	else:
		return

func validate_inputs():
	error_message.visible = false
	firstname.set_error_message()
	lastname.set_error_message()
	password.set_error_message()
	email.set_error_message()
	lrn.set_error_message()
	
	if firstname.error or lastname.error or password.error or email.error or lrn.error:
		return false
	else:
		return true
	
func send_request(data):
	signup_button.disabled = true
	var headers = ["Content-Type: application/json"]
	var url = Globals.url + "createAccount"
	var json = JSON.stringify(data)
	http_request.request(url,headers,HTTPClient.METHOD_POST,json)
	return

func _on_http_request_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	# Convert the response body from bytes to JSON
	var body_text := body.get_string_from_utf8()
	var json: Variant = JSON.parse_string(body_text)

	# Network error (e.g. no internet)
	if result != HTTPRequest.RESULT_SUCCESS:
		error_message.visible = true
		error_message.text = "❌ Network error: " + str(result)
		signup_button.disabled = false
		return

	# Server error (e.g. 400 or 500 response)
	if response_code < 200 or response_code >= 300:
		error_message.visible = true
		signup_button.disabled = false
		if json and "error" in json:
			error_message.text = "⚠️ Message: " + json["error"]
		else:
			error_message.text = "⚠️ Response: " + body_text
		return

	if json:
		signup_button.disabled = false
		var results_tokens = {
				"user_id": json.userId,
				"token": json.result.tokens.token,
				"refresh_token": json.result.tokens.refreshToken
			}
		#save the tokens from convex to json file
		save_token(results_tokens)
		authenticate_user()
		# You can check for something like json["message"] or json["status"]
	else:
		print("⚠️ No JSON body returned.")
		
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
		http_request.request(url, headers, HTTPClient.METHOD_POST,json)

func save_token(tokens)-> void:
	var jsonString = JSON.stringify(tokens)
	var jsonFile = FileAccess.open("user://auth_data.json", FileAccess.WRITE)
	jsonFile.store_line(jsonString)
	jsonFile.close()

func get_all_sections()-> void:
	var headers = ["Content-Type: application/json"]
	var url = Globals.url + "getAllSections"
	get_section.request(url,headers,HTTPClient.METHOD_GET)
	return

func _on_get_section_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
		# Convert the response body from bytes to JSON
	var body_text := body.get_string_from_utf8()
	var json: Variant = JSON.parse_string(body_text)

	# Network error (e.g. no internet)
	if result != HTTPRequest.RESULT_SUCCESS:
		error_message.visible = true
		error_message.text = "❌ Network error: " + str(result)
		signup_button.disabled = false
		return

	# Server error (e.g. 400 or 500 response)
	if response_code < 200 or response_code >= 300:
		error_message.visible = true
		signup_button.disabled = false
		if json and "error" in json:
			error_message.text = "⚠️ Message: " + json["error"]
		else:
			error_message.text = "⚠️ Response: " + body_text
		return

	# Success
	print("✅ Request successful!")
	if json:
		signup_button.disabled = false
		print("📦 Response JSON:", json)
		sections = json.result
		section_dropdown.clear()
		for section in sections:
			section_dropdown.add_item(section["name"])
			
	else:
		print("⚠️ No JSON body returned.")
		
func authenticate_user()->void:
	#check if the email and password is not empty. call the convex auth here
	if email.get_value() != "" or password.get_value() != "":
		var data := {
			"email":email.get_value(),
			"password":password.get_value()
		}
		auth_request(data)
		#check if the email and password is valid then assign the Global variable and navigate to next scene
	else:
		pass
		
func auth_request(data):
	#login_button.text = "Loading"
	#login_button.disabled = true
	var headers = ["Content-Type: application/json"]
	var url = Globals.url + "api/auth/signin"
	var json = JSON.stringify(data)
	auth_http.request(url,headers,HTTPClient.METHOD_POST,json)


func _on_auth_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	#login_button.disabled = false  # Re-enable login button
	var response_text = body.get_string_from_utf8()
	login_button.text = "Login"
	# Handle connection errors
	if result != HTTPRequest.RESULT_SUCCESS:
		#error_message_label.visible = true
		#error_message_label.text = "Connection error. Please check your internet connection."
		
		print(1)
		return

	# Handle invalid HTTP status
	if response_code < 200 or response_code >= 300:
		#error_message_label.visible = true
		#error_message_label.text = "Wrong email or password."
		print(2)
		return

	# Parse JSON response
	var json = JSON.parse_string(response_text)
	if json == null:
		#error_message_label.visible = true
		#error_message_label.text = "Failed to parse server response."
		print(3)
		return

	# Check success field in response
	if json.has("success") and json.success:
		# Login success! Extract and store token
		if json.has("result") and json.result.has("tokens"):
			Globals.is_logged_in = true
			#error_message_label.visible = false
			var tokens = {
				"user_id": json.userId,
				"token": json.result.tokens.token,
				"refresh_token": json.result.tokens.refreshToken
			}
			Globals.user_id = json.userId
			#save the tokens from convex to json file
			await save_token(tokens)
			print(3)
			# Navigate to main scene
			SceneTransition.change_scene("res://scenes/main/novel_select.tscn", false)
		else:
			#error_message_label.visible = true
			#error_message_label.text = "Login failed: No token in response."
			print("Error loging in")
	else:
		#error_message_label.visible = true
		var error_msg: String = json.get("message", "Invalid credentials.")
		#error_message_label.text = "Login failed: " + error_msg
