extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gradelevel = $SignupContainer/GradeLevel/Panel/MarginContainer/HBoxContainer/OptionButton
	$SignupContainer/Section/Panel/MarginContainer/HBoxContainer/OptionButton
	$SignupContainer/Firstname.set_placeholder("First name")
	$SignupContainer/Lastname.set_placeholder("Last name")
	$SignupContainer/Password.set_placeholder("Password")
	$SignupContainer/Password.set_secret_mode(true)
	$SignupContainer/Email.set_placeholder("Email")
	$SignupContainer/LRN.set_placeholder("Student LRN")
	$SignupContainer/Section.set_placeholder("Section")
	
	# Clear any existing items first (optional)
	gradelevel.clear()
	# Add gradelevel options
	var grades = ["Grade 9", "Grade 10"]
	for grade in grades:
		gradelevel.add_item(grade)
	gradelevel.text = "Select Grade level"
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
