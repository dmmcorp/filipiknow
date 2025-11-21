extends PanelContainer

@onready var progress_bar = $TextureProgressBar
@onready var label = $Label
@onready var timer = $Timer


var load_time := 5.0
var elapsed := 0.0
var is_loading := false

var total_time := 10.0
var time_left := 10.0

signal countdown_finished(new_progress)

func _ready():
	# Initialize progress bar and text
	progress_bar.max_value = total_time
	progress_bar.value = total_time
	label.text = str(int(time_left)) + "s"
	
	# Configure timer
	timer.wait_time = 1.0  # fires every second
	timer.start()

func _on_timer_timeout() -> void:
	time_left -= 1.0
	progress_bar.value = time_left
	label.text = str(int(time_left)) + "s"

	if time_left <= 0:
		timer.stop()
		label.text = "Times up!"
		progress_bar.value = 0
		emit_signal("countdown_finished")
