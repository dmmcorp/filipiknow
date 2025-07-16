extends HTTPRequest

@onready var http = $HTTPRequest
var pending_callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func send_http_request(url: String, method: int, body: String = ""):
	var headers = ["Content-Type: application/json"]
	var base_url = Globals.url + url
	http.request(url, headers, method, body)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)
	print("🌐 Response:", json)
