class_name NovelOptions
extends Control

#Tasks
#add the level text label to the levellabel
#if the student is grade 9 lock the elfili_tab
#if grade 10 student lock the noli_tab
#display the chapters/kabanata per tab
#make sure the chapter one is unlocked if the players is new
#if player has chapter data use it to unlock the chapters
var grade_level = "grade 9"
@onready var novel_title_label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer2/NovelTitleLabel
@onready var noli_tab = $PanelContainer/HBoxContainer/Tabs/Noli
@onready var elfili_tab = $PanelContainer/HBoxContainer/Tabs/Elfili
@onready var noli_lock = $PanelContainer/HBoxContainer/Tabs/Noli/TextureRect
@onready var Elfili_lock = $PanelContainer/HBoxContainer/Tabs/Elfili/TextureRect
@onready var levelLabel = $PanelContainer2/HBoxContainer/LevelLabel

var selected_tab = "1"
var original_scale = Vector2.ONE
var hover_scale = Vector2(1.05, 1.05)
var dark_brown = Color(0.88,0.484,0.278)
var brown = Color(1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_grade_checker()
	_set_selected_tab_color()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _grade_checker()-> void:
	if grade_level == "grade 9":
		Elfili_lock.visible = true
		noli_lock.visible = false
		noli_tab.disabled = false
		elfili_tab.disabled = true
	else:
		Elfili_lock.visible = false
		noli_lock.visible = true
		noli_tab.disabled = true
		elfili_tab.disabled = false

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
