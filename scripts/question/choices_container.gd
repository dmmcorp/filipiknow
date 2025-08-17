extends Control

@onready var container = $"."   # scatter area
var answer: Array
var label_theme = preload("res://theme/label_theme.tres")

signal answer_ready(answer: Array)
signal letter_clicked(letter: String, btn: Button)  # pass the button too

# Colors (hex from your request)
var normal_color: Color = Color("#684210")   # not selected
var selected_color: Color = Color("#feb74f") # selected

func _ready() -> void:
	assign_values()
	await get_tree().process_frame
	randomize()
	scatter_letters()

func assign_values():
	if Globals.selected_level.game.identification.has("answer"):
		var text = Globals.selected_level.game.identification.answer
		if text and text.length() > 0:
			answer = text.split("", true)
			emit_signal("answer_ready", answer)

func scatter_letters():
	var area_size = container.size
	var margin_left = get_theme_constant("margin_left", "MarginContainer")
	var margin_top = get_theme_constant("margin_top", "MarginContainer")
	var margin_right = get_theme_constant("margin_right", "MarginContainer")
	var margin_bottom = get_theme_constant("margin_bottom", "MarginContainer")

	var usable_width = area_size.x - margin_left - margin_right
	var usable_height = area_size.y - margin_top - margin_bottom
	var placed_rects: Array[Rect2] = []

	for letter in answer:
		var btn = Button.new()
		btn.text = letter
		btn.theme = label_theme
		btn.add_theme_font_size_override("font_size", 32)  # make text bigger
		btn.flat = true
		btn.modulate = normal_color   # 👈 start with normal color
		container.add_child(btn)

		await get_tree().process_frame
		var size = btn.get_combined_minimum_size()

		var position: Vector2
		var tries := 0
		var max_tries := 100

		while true:
			var rand_x = randf_range(margin_left, margin_left + usable_width - size.x)
			var rand_y = randf_range(margin_top, margin_top + usable_height - size.y)
			position = Vector2(rand_x, rand_y)
			var new_rect = Rect2(position, size)

			var overlaps = false
			for rect in placed_rects:
				if rect.intersects(new_rect):
					overlaps = true
					break

			if not overlaps or tries >= max_tries:
				placed_rects.append(new_rect)
				break
			tries += 1

		btn.position = position

		btn.pressed.connect(func(): 
			if btn.disabled == false:
				btn.modulate = selected_color   # 👈 change to selected color
				emit_signal("letter_clicked", letter, btn)
		)
