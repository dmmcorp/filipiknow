extends Control

@onready var four_pics_grid = $TextureRect/MarginContainer/VBoxContainer/GridContainer
@onready var clue_label = $TextureRect/ClueContainer/PanelContainer/MarginContainer/Label
@onready var clue_container = $TextureRect/ClueContainer
@onready var answer_slots = $TextureRect/MarginContainer/VBoxContainer/CenterContainer/AnswerSlots
@onready var letter_selection = $TextureRect/MarginContainer/VBoxContainer/LetterSelectionCenterContainer/LetterSelection
@onready var clue_button = $TextureRect/MarginContainer/VBoxContainer/ButtonBar/ClueButton
@onready var shuffle_button = $TextureRect/MarginContainer/VBoxContainer/ButtonBar/ShuffleButton

@onready var letter_box = preload("res://scenes/ui/question/letter_box.tscn")
@onready var letter_box_white = preload("res://scenes/ui/question/letter_box_white.tscn")

var correct_answer := ""
var clue := ""
var answer_boxes := []
var letter_buttons: Array = []
var current_answer := []
var four_pics_images :Array= []
var fourPicsOneWord
var max_score
var time_limit

signal submit_assessment(player_answer:String, correct_answer: String, max_score:float, max_time)

func _ready() -> void:
	_show_images()
	_build_answer_slots()
	_build_letter_selection()
	_set_clue()

#it is called on Assessments.gd
func setup(data: Dictionary):
	fourPicsOneWord = data.fourPicsOneWord
	four_pics_images = fourPicsOneWord.images
	correct_answer = fourPicsOneWord.answer.to_upper().strip_edges()
	max_score = data.points
	clue = fourPicsOneWord.clue
	time_limit = data.time_limit
	answer_boxes = correct_answer.split("")
	current_answer = []
	print(fourPicsOneWord)
	
	

func _show_images():
	if fourPicsOneWord.has("images"):
		for i in range(4):
			var tex_rect: TextureRect
			# If the TextureRect already exists in the grid
			if i < four_pics_grid.get_child_count():
				tex_rect = four_pics_grid.get_child(i) as TextureRect
			else:
				# Create a new TextureRect and add it to the grid
				tex_rect = TextureRect.new()
				four_pics_grid.add_child(tex_rect)
			# Assign the texture
			tex_rect.texture = four_pics_images[i] as Texture2D
			tex_rect.expand = true
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	
# ----------------------------------------------------------
#  ANSWER SLOTS
# ----------------------------------------------------------
func _build_answer_slots():
	for child in answer_slots.get_children():
		child.queue_free()
	current_answer.clear()

	for i in range(answer_boxes.size()):
		var letter_instance = letter_box.instantiate()
		answer_slots.add_child(letter_instance)
		var lbl: Label = letter_instance.get_node("Label")
		lbl.text = ""
		current_answer.append("")

		# Bind slot index properly to avoid closure issue
		letter_instance.gui_input.connect(func(event, idx=i):
			if event is InputEventMouseButton and event.pressed:
				_on_slot_clicked(idx))


func _on_slot_clicked(slot_index: int) -> void:
	var slot = answer_slots.get_child(slot_index)
	var lbl: Label = slot.get_node("Label")

	if lbl.text == "":
		return   # nothing to remove

	var removed_letter = lbl.text
	lbl.text = ""
	current_answer[slot_index] = ""

	_return_letter_to_bank(removed_letter)
# ----------------------------------------------------------
#  LETTER SELECTION
# ----------------------------------------------------------
func _build_letter_selection():
	for child in letter_selection.get_children():
		child.queue_free()

	var letters := _generate_letters(correct_answer)

	for letter in letters:
		var letter_btn = letter_box_white.instantiate()
		var lbl = letter_btn.get_node("Label")
		lbl.text = letter

		letter_btn.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				_on_letter_selected(letter_btn)
		)
		letter_selection.add_child(letter_btn)


func _return_letter_to_bank(letter: String):
	_create_letter_button(letter)

func _create_letter_button(letter: String):
	var letter_btn = letter_box_white.instantiate()
	var lbl = letter_btn.get_node("Label")
	lbl.text = letter

	# Connect click
	letter_btn.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			_on_letter_selected(letter_btn)
	)
	letter_selection.add_child(letter_btn)

func _on_letter_selected(letter_btn):
	var letter = letter_btn.get_node("Label").text

	# Find next empty slot
	for i in range(answer_slots.get_child_count()):
		if current_answer[i] == "":
			var slot = answer_slots.get_child(i)
			var lbl: Label = slot.get_node("Label")
			lbl.text = letter
			current_answer[i] = letter
			letter_btn.queue_free()
			break



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

func _on_shuffle_btn_button_down() -> void:
	# Collect letters that are still in the letter_selection (not yet used in answer slots)
	var remaining_letters: Array = []

	for btn in letter_selection.get_children():
		if btn is Control:
			var lbl: Label = btn.get_node("Label")
			var letter = lbl.text
			remaining_letters.append(letter)

	# Shuffle the remaining letters
	remaining_letters.shuffle()

	# Clear the letter selection container
	for child in letter_selection.get_children():
		child.queue_free()

	# Rebuild buttons from shuffled letters
	for letter in remaining_letters:
		var letter_btn = letter_box_white.instantiate()
		var lbl = letter_btn.get_node("Label")
		lbl.text = letter

		letter_btn.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				_on_letter_selected(letter_btn)
		)

		letter_selection.add_child(letter_btn)


# ----------------------------------------------------------
#  Clue functions
# ----------------------------------------------------------
func _set_clue():
	clue_label.text = clue

func _on_clue_button_down() -> void:
	clue_container.visible = true


func _on_close_button_button_down() -> void:
	clue_container.visible = false


# ----------------------------------------------------------
#  Submit answer
# ----------------------------------------------------------
func _check_answer(remaining_time):

	var formed := ""
	for c in current_answer:
		formed += c

	if formed == correct_answer:
		print("✅ Correct!")
	elif not formed.contains(""):
		print("❌ Incorrect!")

func _on_submit_button_button_down() -> void:
	var formed := ""
	for c in current_answer:
		formed += c
	emit_signal("submit_assessment", formed, correct_answer, max_score, time_limit)
