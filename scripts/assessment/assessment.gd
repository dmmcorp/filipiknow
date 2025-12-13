extends Node

@onready var assessment_numbers = $AssessmentNumbers
@onready var timer_ui = $Timer
@onready var BG = $BG
@onready var assessment_container = $AssessmentContainer
@onready var four_pics_one_word = $AssessmentContainer/FourPicsOneWord

var assessments: Array = []
var assessment_default_score: = {
	"number": 1,
	"score": 0,
	"player_answer": "",
	"correct_answer": ""
}
var ass_scores_record:Array = []
var current_assessment_index: int = 0
var current_assessment_scene: Node = null
const SCENES = {
	"4pics1word" = preload("res://scenes/ui/assessment/FourPicsOneWord.tscn")
}

const TIERS = {
	80: 100,  # 80% and up → 100% score
	50: 70,   # 50% and up → 70% score
	20: 40,   # 20% and up → 40% score
	1: 15,    # 1% and up  → 15% score
	0: 0      # 0%        → 0% score
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
	ass_scores_record.append(assessment_default_score)
	current_assessment_index += 1
	if current_assessment_index < assessment_numbers.get_assessment_count():
		assessment_numbers.highlight_assessment(current_assessment_index)
		await get_tree().create_timer(0.3).timeout # small delay for smooth transition
		#timer_ui.start_countdown(10.0)
		_show_assessment(current_assessment_index, assessments)
		print(ass_scores_record)
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
			assessment_default_score = {
				"number": current.assessmentGameNumber,
				"score": 0,
				"player_answer": "",
				"correct_answer": ""
			}
			_show_four_pics(current)
		"whoSaidIt":
			assessment_default_score = {
				"number": current.assessmentGameNumber,
				"score": 0,
				"player_answer": "",
				"correct_answer": ""
			}
			_show_who_said_it(current)
		"jigsawPuzzle":
			assessment_default_score = {
				"number": current.assessmentGameNumber,
				"score": 0,
				"player_answer": "",
				"correct_answer": ""
			}
			_show_jigsaw(current)
		_:
			assessment_default_score = {
				"number": 0,
				"score": 0,
				"player_answer": "",
				"correct_answer": ""
			}
			_clear_assessment_container()
			print("⚠️ Unknown assessment type:", type)
			
func _show_four_pics(data: Dictionary) -> void:
	print("🧩 Displaying Four Pics One Word:", data)
	assessment_default_score.coreect_answer = data.fourPicsOneWord.answer
	# --- 1️⃣ Clear previous assessment scene if any ---
	if current_assessment_scene and current_assessment_scene.is_inside_tree():
		current_assessment_scene.queue_free()
		current_assessment_scene = null

	# --- 2️⃣ Instantiate the FourPicsOneWord scene ---
	var scene_res = preload("res://scenes/ui/assessment/FourPicsOneWord.tscn")
	var scene = scene_res.instantiate()
	scene.submit_assessment.connect(_calculate_score)
	# Optional: if your game scene has a setup() function
	if scene.has_method("setup"):
		scene.setup(data)  # pass data from backend (images, clue, answer, etc.)
		assessment_default_score.number = data.assessmentGameNumber
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
	
func _show_who_said_it(data:Dictionary):
	print("🧩 Displaying Who said it:")
	var cor_ans
	var options = data.whoSaidIt.options
	
	#find the correct answer
	for option in options:
		if option.isCorrect == true:
			cor_ans = option.name
	
	if current_assessment_scene and current_assessment_scene.is_inside_tree():
		current_assessment_scene.queue_free()
		current_assessment_scene = null
	var scene_res = preload("res://scenes/ui/assessment/WhoSaidIt.tscn")
	var scene = scene_res.instantiate()
	scene.submit_assessment.connect(_calculate_score)
	if scene.has_method("setup"):
		scene.setup(data)  # pass data from backend (images, clue, answer, etc.)
		assessment_default_score.number = data.assessmentGameNumber
	
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

func _calculate_score(player_answer:String, correct_answer:String, max_score:float, max_time:float):
	# assign value to assessment_score Dictionary //ass_num //ass_score //ass_ans //ass_cor_ans
	var plyr_ans = player_answer.to_upper()
	var cor_ans = correct_answer.to_upper()
	assessment_default_score.player_answer = plyr_ans
	assessment_default_score.correct_answer = cor_ans.to_upper()
	
	if plyr_ans.to_upper() == cor_ans.to_upper():
		print("Correct answer!")
		var time_left = timer_ui.current_time
		time_left = max(time_left, 0)
		var time_percent = _get_time_percentage(time_left,max_time)
		time_percent = round(time_percent * 100) / 100 
		var tier_value = _get_tier_value(time_percent)
		var score = (float(tier_value) / 100.0) * max_score
		score = max(score,0)
		print("this is the final Score:", score)
		print("this is the final Score:", max_score)
		print("this is the time_left:", time_left)
		print("this is the time_percent:", time_percent)
		print("this is the tier_value:", tier_value)
		assessment_default_score.score = score
	else:
		print("Wrong answer!")
		print("score:", 0)
		assessment_default_score.score = 0
	
func _get_time_percentage(time_left, max_time):
	var time_percent = (time_left / max_time) * 100
	return time_percent
	
func _get_tier_value(time_percent):
	if time_percent >= 80:
		return 100
	elif time_percent >= 50:
		return 70
	elif time_percent >= 20:
		return 40
	elif time_percent >= 1:
		return 15
	elif time_percent <= 0:
		return 0
