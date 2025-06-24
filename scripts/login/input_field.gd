extends Control

@onready var line_edit = $Panel/MarginContainer/HBoxContainer/LineEdit
var value = ""
# Set placeholder text
func set_placeholder(text: String) -> void:
	line_edit.placeholder_text = text

# Set secret mode (for passwords)
func set_secret_mode(is_secret: bool) -> void:
	line_edit.secret = is_secret

func _on_line_edit_text_submitted(new_text: String) -> void:
	pass # Replace with function body.

func _on_line_edit_text_changed(new_text: String) -> void:
	value = new_text
	get_value()

func get_value() -> String:
	return value
