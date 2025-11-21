extends Control

signal time_finished  # 🔔 Emitted when countdown ends

@onready var timer: Timer = $MarginContainer/HBoxContainer/TimerProgressUI/Timer
@onready var progress_bar: TextureProgressBar = $MarginContainer/HBoxContainer/TimerProgressUI/TextureProgressBar
@onready var label: Label = $MarginContainer/HBoxContainer/TimerProgressUI/Label

var total_time := 10.0
var current_time := total_time
var is_animating := false

func _ready():
	timer.wait_time = 1.0
	timer.connect("timeout", Callable(self, "_on_timer_tick"))
	progress_bar.max_value = total_time
	progress_bar.value = total_time
	label.text = str(int(total_time)) + "s"

func start_countdown(duration: float = 10.0):
	if is_animating:
		return # Prevent overlapping fades
	
	total_time = duration
	current_time = duration
	progress_bar.max_value = duration
	progress_bar.value = duration
	label.text = str(int(duration)) + "s"
	
	# Fade in animation
	await _fade_ui(1.0)
	timer.start()

func _on_timer_tick():
	current_time -= 1
	progress_bar.value = current_time
	label.text = str(int(current_time)) + "s"
	
	if current_time <= 0:
		timer.stop()
		progress_bar.value = 0
		label.text = "0s"
		print("⏰ Timer finished!")
		
		# Fade out before signaling
		await _fade_ui(0.0)
		emit_signal("time_finished")

# --- Smooth Fade Animation Function ---
func _fade_ui(target_opacity: float, duration: float = 0.5):
	is_animating = true
	var tween = create_tween()
	tween.tween_property(progress_bar, "modulate:a", target_opacity, duration)
	tween.tween_property(label, "modulate:a", target_opacity, duration)
	await tween.finished
	is_animating = false
