extends Control

@onready var label = $VBoxContainer/Label
@onready var image = $VBoxContainer/PanelContainer/TextureRect
@onready var panel_bg = $PanelContainer
@onready var btn = $Button
@onready var optn = $"."

signal option_selected(selected_option)

func _ready() -> void:
	panel_bg.visible = false


func set_content(text: String, texture: Texture2D):
	label.text = text
	image.texture = texture

func _on_button_button_down() -> void:
	
	emit_signal("option_selected", optn)
