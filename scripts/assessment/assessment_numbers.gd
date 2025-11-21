extends Control

@onready var hbox = $MarginContainer/HBoxContainer
var panels := []
var lines := []

func _ready():
	# Collect all panel containers and lines
	for child in hbox.get_children():
		if child is PanelContainer:
			if "Line" in child.name:
				lines.append(child)
			else:
				panels.append(child)

func get_assessment_count() -> int:
	return panels.size()

func highlight_assessment(index: int):
	for i in range(panels.size()):
		var panel = panels[i]
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(50)
		style.set_border_width_all(7)
		
		if i == index:
			style.border_color = Color("00ff00") # active = green
		
		elif i < index:
			style.border_color = Color("00ccff") # completed = blue
		
		else:
			style.border_color = Color("555555") # pending = gray
		
		
		panel.add_theme_stylebox_override("panel", style)
		
	# Update connecting lines (optional)
	for j in range(lines.size()):
		var line_style := StyleBoxFlat.new()
		
		line_style.set_border_width_all(2)
		
		lines[j].add_theme_stylebox_override("panel", line_style)
