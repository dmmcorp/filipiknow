extends Control

@onready var noli_button = $Noli
@onready var Elfili_button = $Elfili
@onready var novel_options = $NovelOptions
@onready var settings_button = $Settings/SettingsButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_settings_button_button_down() -> void:
	SceneTransition.change_scene("res://scenes/main/settings.tscn")
