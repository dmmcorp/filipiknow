extends Control

@onready var four_pics_grid = $TextureRect/MarginContainer/VBoxContainer/GridContainer
@onready var clue_label = $TextureRect/MarginContainer/VBoxContainer/ClueLabel
@onready var answer_slots = $TextureRect/MarginContainer/VBoxContainer/AnswerSlots
@onready var letter_selection = $TextureRect/MarginContainer/VBoxContainer/LetterSelection
@onready var clue_button = $TextureRect/MarginContainer/VBoxContainer/ButtonBar/ClueButton
@onready var shuffle_button = $TextureRect/MarginContainer/VBoxContainer/ButtonBar/ShuffleButton
@onready var letter_scene = preload("res://scenes/ui/question/letter_container.tscn")

var correct_answer := "Codex"
var clue := ""
var answer_boxes := []
var letter_buttons := []

func setup(data: Dictionary):
	var fourPicsOneWord = data.fourPicsOneWord
	var images = fourPicsOneWord.images
	correct_answer = fourPicsOneWord.answer.to_upper().strip_edges()
	clue = fourPicsOneWord.clue
	print(fourPicsOneWord)
	#_show_images()
	
	# Show images
	#for i in range(4):
		#var tex_rect: TextureRect
		#if i < four_pics_grid.get_child_count():
			#tex_rect = four_pics_grid.get_child(i)
		#else:
			#tex_rect = TextureRect.new()
			#four_pics_grid.add_child(tex_rect)
		#tex_rect.expand = true
		#tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		#tex_rect.texture = load(data.images[i]) if i < data.images.size() else null
#
	## Hide clue text initially
	#clue_label.visible = false
	#clue_label.text = "💡 Clue: " + data.clue
#
	## Build letter slots
	#_build_answer_slots(correct_answer)
#
	## Build selection letters (answer + randoms)
	#var all_letters = _generate_letters(correct_answer)
	#_build_letter_selection(all_letters)
#
	## Connect button actions
	#clue_button.pressed.connect(_on_clue_button_pressed)
	#shuffle_button.pressed.connect(_on_shuffle_button_pressed)

func _show_images(images:Array):
		for i in range(4):
			var tex_rect: TextureRect
			if i < four_pics_grid.get_child_count():
				tex_rect = four_pics_grid.get_child(i)
			else:
				tex_rect = TextureRect.new()
				four_pics_grid.add_child(tex_rect)
			tex_rect.expand = true
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			#tex_rect.texture = load(data.images[i]) if i < data.images.size() else null
#


func _build_answer_slots(answer: String):
	for child in answer_slots.get_children():
		child.queue_free()
	answer_boxes.clear()

	for i in range(answer.length()):
		var lbl = Label.new()
		lbl.text = "_"
		lbl.add_theme_font_size_override("font_size", 28)
		lbl.custom_minimum_size = Vector2(35, 45)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color.WHITE)
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(40, 50)
		panel.add_child(lbl)
		answer_slots.add_child(panel)
		answer_boxes.append(lbl)


func _generate_letters(answer: String) -> Array:
	var letters = []
	for c in answer:
		if c != " ":
			letters.append(c)
	# Add 3 random extra letters
	while letters.size() < answer.replace(" ", "").length() + 3:
		var random_char = String.chr(randi_range(65, 90)) # Random uppercase A-Z
		letters.append(random_char)
	letters.shuffle()
	return letters


func _build_letter_selection(letters: Array):
	for child in letter_selection.get_children():
		child.queue_free()
	letter_buttons.clear()

	for letter in letters:
		var btn = Button.new()
		btn.text = letter
		btn.custom_minimum_size = Vector2(40, 50)
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(_on_letter_pressed.bind(btn))
		letter_selection.add_child(btn)
		letter_buttons.append(btn)


func _on_letter_pressed(btn: Button):
	# Find first empty slot
	for lbl in answer_boxes:
		if lbl.text == "_":
			lbl.text = btn.text
			btn.disabled = true
			break

	# Check if answer complete
	var formed_answer = ""
	for lbl in answer_boxes:
		formed_answer += lbl.text
	formed_answer = formed_answer.strip_edges().to_upper()

	if formed_answer == correct_answer.replace(" ", ""):
		print("✅ Correct answer!")
		_show_result(true)
	elif not formed_answer.contains("_"):
		print("❌ Wrong answer!")
		_show_result(false)


func _show_result(is_correct: bool):
	for btn in letter_buttons:
		btn.disabled = true
	if is_correct:
		modulate = Color(0, 1, 0, 0.8)
	else:
		modulate = Color(1, 0, 0, 0.8)
	await get_tree().create_timer(1.0).timeout
	modulate = Color(1, 1, 1, 1)
	_reset_answer()


func _reset_answer():
	for lbl in answer_boxes:
		lbl.text = "_"
	for btn in letter_buttons:
		btn.disabled = false


func _on_clue_button_pressed():
	clue_label.visible = !clue_label.visible


func _on_shuffle_button_pressed():
	var letters = []
	for btn in letter_buttons:
		letters.append(btn.text)
	letters.shuffle()
	_build_letter_selection(letters)
