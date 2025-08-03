extends Control

@onready var texture_button = $Portrait
@onready var label = $KabanataLabel

@export var character_id: String = ""
@export var is_locked: bool = false
@export var display_name: String = ""
@export var icon_path: String = ""

signal character_selected(character_id: String)

func _ready():
	label.text = display_name
	texture_button.disabled = is_locked
	if icon_path != "":
		texture_button.texture_normal = load("res://assets/images/codex-frame.png")

	texture_button.pressed.connect(_on_button_pressed)
	
	print("Icon Path:", icon_path)
	print("Loaded Texture:", texture_button.texture_normal)
	
func _on_button_pressed():
	character_selected.emit(character_id)
