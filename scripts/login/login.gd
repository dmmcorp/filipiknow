class_name Login
extends Control

@onready var email = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/Email
@onready var password = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/Password
@onready var signup_button = $CenterContainer/LoginContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var signup = "res://scenes/main/signup.tscn"

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
		get_tree().change_scene_to_file(signup)
