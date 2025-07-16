class_name Login
extends Control

@onready var email = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/Email
@onready var password = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/Password
@onready var login_button = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/LoginBtnContainer/Button
@onready var signup = "res://scenes/main/signup.tscn"
@onready var error_message_label = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/ErrorMessageLabel
@onready var http_request = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/LoginBtnContainer/Button/HTTPRequest
@onready var loader = $Loader
var data := {
		"email":"",
		"password":""
	}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_connection_signal()
	email.set_placeholder("Username")
	password.set_placeholder("Password")
	password.set_secret_mode(true)

func handle_connection_signal() -> void:
	pass
	
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	if meta == "signup":
		SceneTransition.change_scene(signup)

#Login button pressed
func _on_button_button_down() -> void:
	data.email = email.get_value()
	data.password = password.get_value()
	authenticate_user()
	
#sample simulation function only(use the convex backend)
func authenticate_user()->void:
	login_button.disabled = true
	#check if the email and password is not empty. call the convex auth here
	if data.email != "" or data.password != "":
		error_message_label.visible = false
		send_request(data)
		#check if the email and password is valid then assign the Global variable and navigate to next scene
	else:
		error_message_label.visible = true
		error_message_label.text = "Email or Password is required."
		login_button.disabled = false
		
func send_request(data):
	loader.visible = true
	login_button.text = "Logging in"
	login_button.disabled = true
	var headers = ["Content-Type: application/json"]
	var url = Globals.url + "api/auth/signin"
	var json = JSON.stringify(data)
	http_request.request(url,headers,HTTPClient.METHOD_POST,json)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	login_button.disabled = false  # Re-enable login button
	loader.visible = false
	var response_text = body.get_string_from_utf8()
	login_button.text = "Login"
	# Handle connection errors
	if result != HTTPRequest.RESULT_SUCCESS:
		error_message_label.visible = true
		error_message_label.text = "❌ Connection error. Please check your internet connection."
		return

	# Handle invalid HTTP status
	if response_code < 200 or response_code >= 300:
		error_message_label.visible = true
		error_message_label.text = "❌ Wrong email or password."
		return

	# Parse JSON response
	var json = JSON.parse_string(response_text)
	if json == null:
		error_message_label.visible = true
		error_message_label.text = "❌ Failed to parse server response."
		return

	# Check success field in response
	if json.has("success") and json.success:
		# Login success! Extract and store token
		if json.has("result") and json.result.has("tokens"):
			Globals.is_logged_in = true
			error_message_label.visible = false
			var tokens = {
				"user_id": json.userId,
				"token": json.result.tokens.token,
				"refresh_token": json.result.tokens.refreshToken
			}
			#save the tokens from convex to json file
			await save_token(tokens)
			
			# Navigate to main scene
			SceneTransition.change_scene("res://scenes/main/novel_select.tscn", false)
		else:
			error_message_label.visible = true
			error_message_label.text = "❌ Login failed: No token in response."
	else:
		error_message_label.visible = true
		var error_msg: String = json.get("message", "Invalid credentials.")
		error_message_label.text = "❌ Login failed: " + error_msg

func save_token(tokens)-> void:
	var jsonString = JSON.stringify(tokens)
	var jsonFile = FileAccess.open("user://auth_data.json", FileAccess.WRITE)
	jsonFile.store_line(jsonString)
	jsonFile.close()
	print("✅ Logged in. Token stored.")
