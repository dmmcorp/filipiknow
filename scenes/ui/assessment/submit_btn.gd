extends TextureButton

signal submit_assessment(player_answer:String, correct_answer: String, max_score:float)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.assessment_submit_btn = self


func _on_button_down(current_answer:String, correct_answer: String, max_score:float) -> void:
	print('submit')
	emit_signal("submit_assessment", current_answer, correct_answer, max_score)
