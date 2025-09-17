extends ScrollContainer

var dragging := false
var last_drag_position := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			last_drag_position = event.position
		else:
			dragging = false

	elif event is InputEventScreenDrag and dragging:
		var delta = event.position - last_drag_position
		last_drag_position = event.position

		# Invert Y so dragging up moves content down
		scroll_vertical -= int(delta.y)
		scroll_horizontal -= int(delta.x)
