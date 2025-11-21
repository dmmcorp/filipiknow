extends Node

@onready var assessment_numbers = $AssessmentNumbers
@onready var timer_ui = $Timer
@onready var BG = $BG
@onready var assessment_container = $AssessmentContainer
@onready var four_pics_one_word = $AssessmentContainer/FourPicsOneWord

var assessments: Array = []
var current_assessment_index: int = 0
var current_assessment_scene: Node = null
const SCENES = {
	"4pics1word" = preload("res://scenes/ui/assessment/FourPicsOneWord.tscn")
}

func _ready():
	await get_tree().process_frame
	if Globals.assessments and Globals.assessments.size() > 0:
		setup_assessments(Globals.assessments)
	else:
		push_error("⚠️ No assessments loaded in Globals!")
		
	timer_ui.time_finished.connect(_on_time_finished)
	assessment_numbers.highlight_assessment(current_assessment_index)
	BG.texture = Globals.chapter_resource.result.novel_metadata.bg_image
	SceneTransition.animation_player.play_backwards("dissolve")
	await SceneTransition.animation_player.animation_finished


func _on_time_finished():
	current_assessment_index += 1
	if current_assessment_index < assessment_numbers.get_assessment_count():
		assessment_numbers.highlight_assessment(current_assessment_index)
		await get_tree().create_timer(0.3).timeout # small delay for smooth transition
		timer_ui.start_countdown(10.0)
		_show_assessment(current_assessment_index, assessments)
	else:
		print("✅ All assessments completed!")
		
func setup_assessments(data: Array) -> void:
	assessments = data
	assessments.sort_custom(func(a, b):
		return a.get("assessmentGameNumber", 0) < b.get("assessmentGameNumber", 0)
	)
	for a in assessments:
		print("- #%d %s" % [a.get("assessmentGameNumber"), a.get("gameType")])

	# Load the first assessment
	_show_assessment(current_assessment_index, assessments)

func _show_assessment(index: int, data:Array) -> void:
	if assessment_container:
		for child in assessment_container.get_children():
			child.queue_free()
			
	if index >= data.size():
		print("✅ All assessments completed!")
		return

	var current = data[index]
	var type = current.get("gameType", "")
	
	
	match type:
		"4pics1word":
			_show_four_pics(current)
		"multipleChoice":
			_show_multiple_choice(current)
		"jigsawPuzzle":
			_show_jigsaw(current)
		_:
			_clear_assessment_container()
			print("⚠️ Unknown assessment type:", type)
			
func _show_four_pics(data: Dictionary) -> void:
	print("🧩 Displaying Four Pics One Word:", data)

	# --- 1️⃣ Clear previous assessment scene if any ---
	if current_assessment_scene and current_assessment_scene.is_inside_tree():
		current_assessment_scene.queue_free()
		current_assessment_scene = null

	# --- 2️⃣ Instantiate the FourPicsOneWord scene ---
	var scene_res = preload("res://scenes/ui/assessment/FourPicsOneWord.tscn")
	var scene = scene_res.instantiate()

	# Optional: if your game scene has a setup() function
	if scene.has_method("setup"):
		scene.setup(data)  # pass data from backend (images, clue, answer, etc.)

	# --- 3️⃣ Add to the AssessmentContainer ---
	if assessment_container:
		assessment_container.add_child(scene)
		current_assessment_scene = scene
	else:
		push_warning("⚠️ assessment_container not found! Make sure it’s assigned.")

	# --- 4️⃣ Start the timer for this assessment ---
	var time_limit = data.get("time_limit", 10) # default to 10s if missing
	if timer_ui and timer_ui.has_method("start_countdown"):
		timer_ui.start_countdown(time_limit)
	else:
		push_warning("⚠️ timer_ui not found or missing start_countdown() function!")

	print("▶️ Started FourPicsOneWord with time limit:", time_limit, "seconds.")
	


func _show_multiple_choice(data: Dictionary):
	print("Displaying Multiple Choice:", data)
	# Load your MCQ UI here


func _show_jigsaw(data: Dictionary):
	print("Displaying Jigsaw Puzzle:", data)
	# Load jigsaw logic/UI here

func _clear_assessment_container() -> void:
	if assessment_container:
		if timer_ui and timer_ui.has_method("start_countdown"):
			timer_ui.start_countdown(10)
		else:
			push_warning("⚠️ timer_ui not found or missing start_countdown() function!")
		for child in assessment_container.get_children():
			child.queue_free()
				
func set_bg():
 # adjust path to your actual node
	print("This is the BG:",Globals.chapter_resource.result.novel_metadata.bg_image)
	# Safely extract the bg_image value
	var chapter_meta = Globals.chapter_resource.result.novel_metadata
	var chapter_bg_image = ""

	if chapter_meta.has("bg_image") and typeof(chapter_meta.bg_image) == TYPE_STRING:
		chapter_bg_image = chapter_meta.bg_image
	else:
		push_warning("⚠️ No valid background image found in chapter metadata.")
		return

	print("🖼 Loading background image:", chapter_bg_image)

	# Try to get cached texture
	var texture: Texture2D = await CacheMngr.get_cached_image(chapter_bg_image)

	if texture:
		BG.texture = texture
		BG.visible = true
		print("✅ Background image set successfully (cached or fetched).")
	else:
		push_warning("❌ Failed to load background image from cache or URL.")

func get_image(image_url) -> Texture2D:
	if typeof(image_url) == TYPE_STRING:
		if image_url.begins_with("res://"):
			return load(image_url) as Texture2D
		else:
			# External file (e.g. from user storage)
			var img := Image.load_from_file(image_url)
			if img:
				return ImageTexture.create_from_image(img)
	elif image_url is Texture2D:
		return image_url
	
	push_error("Unsupported image_url: " + str(image_url))
	return null
