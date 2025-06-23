extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var popup = $Panel/MarginContainer/HBoxContainer/OptionButton.get_popup()
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
