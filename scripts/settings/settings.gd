extends Control

@onready var modal = $LogoutPopup
@onready var logout_modal_trigger = $LogoutModalTrigger
@onready var http_request = $LogoutPopup/TextureRect/Yes/HTTPRequest
@onready var error_label = $LogoutPopup/TextureRect/ErrorLabel
@onready var yes_button = $LogoutPopup/TextureRect/Yes

func _ready() -> void:
	modal.visible = false
	error_label.visible = false

func _process(delta: float) -> void:
	pass

func _on_logout_modal_trigger_button_down() -> void:
	modal.visible = true
	$AnimationPlayer.play("pop_up")

func _on_no_button_down() -> void:
	$AnimationPlayer.play_backwards("pop_up")
	await $AnimationPlayer.animation_finished
	modal.visible = false

func _on_yes_button_down() -> void:
	sign_out()

func sign_out() -> void:
	yes_button.disabled = true
	error_label.visible = false

	var headers = ["Content-Type: application/json"]
	var url = Globals.url + "api/auth/signout"  # Make sure this is the correct endpoint
	http_request.request(url, headers, HTTPClient.METHOD_POST, "")  # POST with empty body

func _on_http_request_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var body_text = body.get_string_from_utf8()
	var json = JSON.parse_string(body_text)

	# Check for network error
	if result != HTTPRequest.RESULT_SUCCESS:
		error_label.visible = true
		error_label.text = "❌ Network error: " + str(result)
		yes_button.disabled = false
		return

	# Check for unsuccessful response code
	if response_code < 200 or response_code >= 300:
		error_label.visible = true
		error_label.text = "❌ Server error: HTTP " + str(response_code)
		if json and "error" in json:
			error_label.text += "\n⚠️ " + str(json["error"])
		else:
			error_label.text += "\n⚠️ Unexpected response."
		yes_button.disabled = false
		return

	# Sign-out success
	print("✅ Sign-out successful.")
	SceneTransition.change_scene("res://scenes/main/login.tscn")  # Redirect to login


func _on_back_button_button_down() -> void:
	SceneTransition.change_scene("res://scenes/main/novel_select.tscn", "move_left")
