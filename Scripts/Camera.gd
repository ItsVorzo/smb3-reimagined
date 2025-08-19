extends Camera2D

var center_x = 0.0
var center_y = 0.0
var shift_x: float = 0.0
var shift_y: float = 0.0
var top_margin: float = 70.0
var bottom_margin: float = -48.0
@onready var Plr: CharacterBody2D = $"../Player"
@onready var camlimit_left := $"../CameraLimitLeft"
@onready var camlimit_right := $"../CameraLimitRight"


var frozen := false
var frozen_position := Vector2.ZERO

func _ready() -> void:
	# Get the camera center
	center_x = (get_viewport().get_visible_rect().size.x / 2) / 3 # i divided by 3 because this game resolution is too high, will change this in the future
	center_y = (get_viewport().get_visible_rect().size.y / 2) / 3

func _process(_delta: float) -> void:
	if frozen:
		# Keep camera completely locked
		global_position = frozen_position
		return

	# CameraMode handling from ConfigManager
	match ConfigManager.option_indices["CameraMode"]:
		0: # off
			shift_x = 0
		1: # fixed panning
			if abs(Plr.velocity.x) > 0:
				shift_x = MathFunc.approach(shift_x, 30.0 * Plr.facing_direction, 0.8)
			elif Plr.velocity.x == 0:
				shift_x = MathFunc.approach(shift_x, 0, 0.5)
		2: # smooth panning
			if abs(Plr.velocity.x) > 0:
				shift_x = lerp(shift_x, Plr.velocity.x / 5.0, 0.1)
			elif Plr.velocity.x == 0:
				shift_x = lerp(shift_x, 0.0, 0.1)

	# Move the camera horizontally
	var camera_x = clamp(Plr.global_position.x + shift_x, camlimit_left.position.x + center_x, camlimit_right.position.x - center_x)

	# Move the camera vertically
	var final_y_pos = global_position.y
	# When we will have tanooki this will work
	# Vertical camera moving
	if Plr.global_position.y < global_position.y - top_margin:
		final_y_pos = Plr.position.y + top_margin
	if Plr.global_position.y > global_position.y + bottom_margin:
		final_y_pos = Plr.global_position.y - bottom_margin

	# Apply position if not frozen
	global_position.x = camera_x
	global_position.y = final_y_pos + shift_y

	# Don't let the player go offscreen
	Plr.global_position.x = clamp(Plr.global_position.x, camlimit_left.global_position.x + 16, camlimit_right.global_position.x - 16)
	if Plr.global_position.x <= camlimit_left.global_position.x + 16 and Plr.velocity.x < 0 or Plr.global_position.x >= camlimit_right.global_position.x - 16 and Plr.velocity.x > 0:
		Plr.velocity.x = 0

func freeze_here():
	frozen = true
	frozen_position = global_position
