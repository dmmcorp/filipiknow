extends Control

@onready var close_button = $CloseButton

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_close_button_button_down() -> void:
	SceneTransition.change_scene("res://scenes/main/novel_select.tscn")	
