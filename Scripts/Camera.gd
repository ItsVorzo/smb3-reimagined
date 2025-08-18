extends Camera2D

var shift_x: float = 0.0
var shift_y: float = 0.0
var top_margin: float = 70.0
var bottom_margin: float = 0.0
@onready var Plr: CharacterBody2D = $"../Player"

var frozen := false
var frozen_position := Vector2.ZERO

func _ready() -> void:
	position.x = Plr.position.x
	position.y = Plr.position.y + 70

func _process(_delta: float) -> void:
	if frozen:
		# Keep camera completely locked
		global_position = frozen_position
		return

	# Basic vertical shift
	if Plr.velocity.y >= 270:
		shift_y = MathFunc.approach(shift_y, 80.0, 1.5)
	elif Plr.velocity.y <= 0:
		shift_y = MathFunc.approach(shift_y, 0.0, 1)

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

	var final_y_pos = global_position.y
	#when we will have tanooki this will work
	#if Plr.global_position.y < global_position.y - top_margin:
	#	final_y_pos = Plr.position.y + top_margin
	#if Plr.global_position.y > global_position.y + bottom_margin:
	#	final_y_pos = Plr.global_position.y - bottom_margin
	#print(Plr.global_position.y < global_position.y - top_margin)

	# Apply position if not frozen
	global_position.x = Plr.global_position.x + shift_x
	global_position.y = Plr.global_position.y + shift_y

func freeze_here():
	frozen = true
	frozen_position = global_position
