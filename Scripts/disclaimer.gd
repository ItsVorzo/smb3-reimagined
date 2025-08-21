extends Node2D

@onready var disclaimer_warning = $DisclaimerWarning
@onready var disclaimer_text = $DisclaimerText
@onready var warning_sound = $DisclaimerWarningShow
@onready var text_sound = $DisclaimerTextShow

var can_skip: bool = false

func _ready() -> void:
	# Hide everything initially
	disclaimer_warning.visible = false
	disclaimer_text.visible = false
	can_skip = false

	# Step 1: Show warning + play sound
	disclaimer_warning.visible = true
	warning_sound.play()

	# Step 2: When warning sound finishes → show text + play text sound
	warning_sound.finished.connect(func():
		disclaimer_text.visible = true
		text_sound.play()

		# Step 3: After text is shown, allow skipping
		can_skip = true
	)

func _process(_delta) -> void:
	if can_skip and InputManager.Apress:
		get_tree().change_scene_to_file("res://Scenes/UI/TitleScreen.tscn")
