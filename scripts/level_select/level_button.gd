extends Button

@onready var btn = $"."
var original_scale = Vector2.ONE
var hover_scale = Vector2(1.05, 1.05)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_mouse_entered() -> void:
	btn.scale = hover_scale


func _on_mouse_exited() -> void:
	btn.scale = original_scale
