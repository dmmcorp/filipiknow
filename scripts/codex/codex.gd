extends Control

@onready var close_button = $CloseContainer/CloseButton

#@onready var left_page = $LeftPage
#var char_button_scene = preload("res://scenes/ui/codex/CharacterButton.tscn")
#
#var character_data = {
	#"ibarra": {
		#"display_name": "IBARRA",
		#"locked": false,
		#"icon": "res://assets/images/codex-ibarra.png"
	#},
	#"kab2": {
		#"display_name": "KABANATA 2",
		#"locked": true,
		#"icon": "res://assets/images/codex-locked-frame.png"
	#},
	#"kab3": {
		#"display_name": "KABANATA 3",
		#"locked": true,
		#"icon": "res://assets/images/codex-locked-frame.png"
	#},
	#"kab4": {
		#"display_name": "KABANATA 4",
		#"locked": true,
		#"icon": "res://assets/images/codex-locked-frame.png"
	#},
	#"kab5": {
		#"display_name": "KABANATA 5",
		#"locked": true,
		#"icon": "res://assets/images/codex-locked-frame.png"
	#},
	#"kab6": {
		#"display_name": "KABANATA 6",
		#"locked": true,
		#"icon": "res://assets/images/codex-locked-frame.png"
	#},
#}
#
func _ready() -> void:
	pass
	#for id in character_data.keys():
		#var info = character_data[id]
		#var button = char_button_scene.instantiate()
		#
		#button.character_id = id
		#button.display_name = info.display_name
		#button.is_locked = info.locked
		#button.icon_path = info.icon
		#
		#button.character_selected.connect(_on_character_selected)
		#left_page.add_child(button)

func _process(delta: float) -> void:
	pass
	
func _on_close_button_button_down() -> void:
	SceneTransition.change_scene("res://scenes/main/novel_select.tscn")	

#func _on_character_selected(character_id: String) -> void:
	#print("Selected character:", character_id)
