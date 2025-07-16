extends Control

@onready var line: Line2D = $Line2D
@onready var button1 = $TextureButton
@onready var button2 = $TextureButton2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line.clear_points()
	line.add_point(get_center(button1))
	line.add_point(get_center(button2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_center(btn):
	var pos = btn.position
	var size = btn.size
	var center = pos + size / 2
	
	return center
