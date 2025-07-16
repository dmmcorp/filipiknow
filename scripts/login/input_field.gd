extends Control

@onready var line_edit = $VBoxContainer/Panel/MarginContainer/HBoxContainer/LineEdit
@onready var error_label = $VBoxContainer/Label
var error = false
var value = ""
# Set placeholder text
func set_placeholder(text: String) -> void:
	line_edit.placeholder_text = text

func set_error_message()->void:
	if line_edit.text == "":
		error_label.text = "*Required."
		error_label.visible = true
		error = true
	else:
			#validates email
		if line_edit.placeholder_text == "Email" and "@" not in line_edit.text:
			error_label.text = "*Invalid Email."
			error_label.visible = true
			error = true
			return
		
		#validate length of the password
		if line_edit.placeholder_text == "Password" and line_edit.text.strip_edges().length() > 0 and line_edit.text.length() < 6:
			error_label.text = "*Password must be at least 6 characters."
			error_label.visible = true
			error = true
			return
			
		error_label.visible = false
		error_label.text = ""
		error = false

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
