class_name NovelOptions
extends Control

#Tasks
#add the level text label to the levellabel
#if the student is grade 9 lock the elfili_tab
#if grade 10 student disable the noli_tab
#display the chapters/kabanata per tab
#make sure the chapter one is unlocked if the players is new
#if player has chapter data use it to unlock the chapters
var grade_level = "grade 10"
@onready var novel_title_label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/NovelTitleLabel
@onready var noli_tab = $PanelContainer/HBoxContainer/Tabs/Noli
@onready var elfili_tab = $PanelContainer/HBoxContainer/Tabs/Elfili
@onready var noli_lock = $PanelContainer/HBoxContainer/Tabs/Noli/TextureRect
@onready var Elfili_lock = $PanelContainer/HBoxContainer/Tabs/Elfili/TextureRect
@onready var levelLabel = $PanelContainer2/HBoxContainer/LevelLabel
@onready var chapter_list = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/ChaptersContainer
@onready var selected_chapter_label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/SelectedChapter
var selected_tab = "1"
var original_scale = Vector2.ONE
var hover_scale = Vector2(1.05, 1.05)
var dark_brown = Color(0.88,0.484,0.278)
var brown = Color(1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_grade_checker()
	_set_selected_tab_color()
	_create_chapters()
	#get the current level in the chapter
	_get_chapter_level()

func _grade_checker()-> void:
	if grade_level == "grade 9":
		Elfili_lock.visible = true
		noli_lock.visible = false
		noli_tab.disabled = false
		elfili_tab.disabled = true
		selected_tab = "1"
		novel_title_label.text = "Noli me tangere"
	else:
		Elfili_lock.visible = false
		noli_lock.visible = true
		noli_tab.disabled = true
		elfili_tab.disabled = false
		selected_tab = "2"
		novel_title_label.text = "El Filibusterismo"

func _set_selected_tab_color()-> void:
	if selected_tab == "1":
		noli_tab.self_modulate = dark_brown
		elfili_tab.self_modulate = brown
	else:
		noli_tab.self_modulate = brown
		elfili_tab.self_modulate = dark_brown

func _on_noli_button_down() -> void:
	novel_title_label.text = "Noli me tangere"
	selected_tab = "1"
	_set_selected_tab_color()
func _on_elfili_button_down() -> void:
	novel_title_label.text = "El Filibusteresmo"
	selected_tab = "2"
	_set_selected_tab_color()
	
func _on_noli_mouse_entered() -> void:
	noli_tab.scale = hover_scale

func _on_noli_mouse_exited() -> void:
	noli_tab.scale = original_scale

func _on_elfili_mouse_entered() -> void:
	elfili_tab.scale = hover_scale

func _on_elfili_mouse_exited() -> void:
	elfili_tab.scale = original_scale

func _create_chapters()-> void:
	var chapters_count = 0
	if grade_level == "grade 9":
		chapters_count = 65
	else:
		chapters_count = 40
	for i in range(1, chapters_count):
		var btn = Button.new()
		btn.disabled = true
		_set_chapters_theme(btn, i, "chapters")
		if i > Globals.novel.chapter:
			btn.disabled = true
			btn.icon = load("res://assets/images/lock.png")
		else:
			btn.disabled = false

func _create_levels()-> void:
	for i in range(1, 11):
		var btn = Button.new()
		if i > Globals.novel.level:
			btn.disabled = true
			btn.icon = load("res://assets/images/lock.png")
		_set_chapters_theme(btn, i, "levels")
		
func _set_chapters_theme(btn:Button, i, type)-> void:
	if type == "chapters":
		btn.text = "KABANATA %d" % i
	else:
		btn.text = "Level %d" % i
	btn.theme = load("res://theme/button_theme.tres")
	btn.theme_type_variation = "chapter"
	btn.size_flags_horizontal = Control.SIZE_FILL
	btn.connect("pressed", Callable(self, "_on_chapter_pressed").bind(btn,i))
	chapter_list.add_child(btn)


func _on_chapter_pressed(btn, chapter_num: int) -> void:
	print("Chapter %d pressed" % chapter_num)
	var tween := create_tween()
	#get the current level in the chapter
	_get_chapter_level()
	selected_chapter_label.visible = true
	selected_chapter_label.text = btn.text
	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(btn, "scale", Vector2(1, 1), 0.1)
	for button in chapter_list.get_children():
		if button is Button:
			button.visible = false
	_create_levels()

func on_level_pressed(btn, chapter_num: int) -> void:
	var tween := create_tween()
func _get_chapter_level()-> void:
	levelLabel.text = str(Globals.novel.level)
