extends Control

@onready var btn = $Button
@onready var lock_icon = load("res://assets/images/lock.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_icon()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_icon():
	btn.icon = lock_icon
