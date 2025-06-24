extends Control

@onready var play_button = $CenterContainer/VBoxContainer/Play_Button
@onready var quit_button = $CenterContainer/VBoxContainer/Quit_Button
@onready var login = "res://scenes/main/login.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_connection_signal()

func on_play_pressed() -> void:
	get_tree().change_scene_to_file(login)
	
func on_quit_pressed() -> void:
	get_tree().quit()

func handle_connection_signal() -> void:
	play_button.button_down.connect(on_play_pressed)
	quit_button.button_down.connect(on_quit_pressed)
