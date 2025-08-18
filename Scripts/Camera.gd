extends Camera2D

var shift_x: float = 0.0
var shift_y: float = 0.0
@onready var Plr: Node2D = get_parent()

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
			shift_x = MathFunc.approach(shift_x, 0, 0.5)
		1: # fixed panning
			if abs(Plr.velocity.x) > 0 and InputManager.direction == sign(Plr.velocity.x):
				shift_x = MathFunc.approach(shift_x, 30.0 * Plr.facing_direction, 0.8)
			elif Plr.velocity.x == 0:
				shift_x = MathFunc.approach(shift_x, 0, 0.5)
		2: # smooth panning
			if abs(Plr.velocity.x) > 0 and InputManager.direction == sign(Plr.velocity.x):
				shift_x = lerp(shift_x, Plr.velocity.x / 5.0, 0.1)
			elif Plr.velocity.x == 0:
				shift_x = lerp(shift_x, 0.0, 0.1)

	# Apply position if not frozen
	position.x = shift_x
	position.y = shift_y

func freeze_here():
	frozen = true
	frozen_position = global_position
