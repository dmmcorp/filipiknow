extends Node


# Called when the node enters the scene tree for the first time.
var url := "https://tangible-chicken-583.convex.site/"
var is_logged_in := false
var user_email := ""
var user_firstname := ""
var user_lastname := ""
var novel:= {
	"title": "Noli me tangere",
	"chapter": 1,
	"level": 1,
}

func auth_guard(http_request: HTTPRequest)->void:
	var tokens = load_auth_data()
	if  tokens.has("token"):
		verify_token(tokens["token"], http_request)
	else: 
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
	var url = Globals.url + "api/auth/me"
	request.request(url, headers, HTTPClient.METHOD_POST, "")
