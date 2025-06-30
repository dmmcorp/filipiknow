extends Control

@onready var play_button = $CenterContainer/VBoxContainer/Play_Button
@onready var quit_button = $CenterContainer/VBoxContainer/Quit_Button
@onready var login = "res://scenes/main/login.tscn"
@onready var http_request = $CenterContainer/VBoxContainer/Play_Button/HTTPRequest
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_connection_signal()

func on_play_pressed() -> void:
	#check if the user token is not expired then autologin
	Globals.auth_guard(http_request)
	
func on_quit_pressed() -> void:
	get_tree().quit()

func handle_connection_signal() -> void:
	play_button.button_down.connect(on_play_pressed)
	quit_button.button_down.connect(on_quit_pressed)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)
	if json and json.get("success", false):
		print("✅ Auto-login successful")
		SceneTransition.change_scene("res://scenes/main/novel_select.tscn")
	else:
		print("❌ Auto-login failed. Show login screen.")
		SceneTransition.change_scene("res://scenes/main/login.tscn")
