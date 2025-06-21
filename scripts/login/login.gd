extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Username.set_placeholder("Username")
	$Password.set_placeholder("Password")
	$Password.set_secret_mode(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
