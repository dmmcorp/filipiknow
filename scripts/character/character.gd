extends Control

@onready var character_left = $HBoxContainer/CharacterLeft
@onready var character_right = $HBoxContainer/CharacterRight
@onready var animation_player_left = $HBoxContainer/CharacterLeft/AnimationPlayerLeft
@onready var animation_player_right= $HBoxContainer/CharacterRight/AnimationPlayerRight

const NOT_SPEAKING_COLOR = Color(0.169, 0.169, 0.169)
const SPEAKING_COLOR = Color(1.0, 1.0, 1.0)

var character_positions: Dictionary = {}  # Stores where each character goes
var position_order := ["LEFT", "RIGHT"]
var current_speaking: String
var speaker_names: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speaker_names = []
	pass # Replace with function body.
	
func get_character_position(char_name: String) -> String:
	if character_positions.has(char_name):
		return character_positions[char_name]
	# Find the next available position
	for pos in position_order:
		if pos not in character_positions.values():
			character_positions[char_name] = pos
			return pos

	# All taken: fallback to CENTER
	character_positions[char_name] = "LEFT"
	return "LEFT"
#call every process line

func assign_character(image_url, char_name: String) -> void:
	#If no name and no image clear both character slots
	if (char_name == "" or char_name == null) and (image_url == "" or image_url == null):
		character_left.texture = null
		character_right.texture = null
		print("Cleared characters because no name and no image provided")
		return

	var position := get_character_position(char_name)
	add_speaker_name(char_name, position)
	var texture: Texture2D = null

	#Load texture safely
	if typeof(image_url) == TYPE_STRING and image_url != "":
		texture = load(image_url) as Texture2D
	elif image_url is Texture2D:
		texture = image_url
	elif image_url == "" or image_url == null:
		texture = null
	else:
		push_error("Unsupported image_url type: " + str(typeof(image_url)))
		return

	var pos = position.to_upper()

	if pos == "LEFT":
		character_left.texture = texture
		if texture:
			animation_player_left.play("fade_in_left")
			animation_player_right.play_backwards("fade_in_right")
		else:
			# fade out if no texture
			animation_player_left.play_backwards("fade_in_left")
	elif pos == "RIGHT":
		character_right.texture = texture
		if texture:
			animation_player_right.play("fade_in_right")
			animation_player_left.play_backwards("fade_in_left")
		else:
			# fade out if no texture
			animation_player_right.play_backwards("fade_in_right")


#add speaker name to the speaker_names array
func add_speaker_name(char_name:String, position: String):
	if speaker_names.has(char_name):
		pass
	else:
		speaker_names.append(char_name)
		
