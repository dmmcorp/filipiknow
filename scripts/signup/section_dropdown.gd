extends Control
@onready var dropdown = $VBoxContainer/Panel/MarginContainer/HBoxContainer/OptionButton
var selected_item
@onready var error_label = $VBoxContainer/Label

signal section_selected(section: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var popup = $VBoxContainer/Panel/MarginContainer/HBoxContainer/OptionButton.get_popup()
	popup.hide_on_checkable_item_selection = false  # Optional
	popup.clear()  # Optional: clear old items
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.9, 0.9, 250)
	style_normal.set_corner_radius_all(8)
	popup.add_theme_stylebox_override("panel", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(217, 187, 133)
	popup.add_theme_stylebox_override("hover", style_hover)
	popup.add_theme_color_override("font_color", Color.BLACK)
	popup.add_theme_color_override("font_color_hover", Color.WHITE)
	popup.add_theme_color_override("font_color_pressed", Color.DIM_GRAY)

func _on_option_button_item_selected(index: int) -> void:
	var text = dropdown.get_item_text(index)
	emit_signal("section_selected", text)
	
func set_error_message():
	error_label.visible = true
