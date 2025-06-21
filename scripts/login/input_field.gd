extends Control

@onready var line_edit = $Panel/MarginContainer/HBoxContainer/LineEdit

# Set placeholder text
func set_placeholder(text: String) -> void:
	line_edit.placeholder_text = text

# Set secret mode (for passwords)
func set_secret_mode(is_secret: bool) -> void:
	line_edit.secret = is_secret
