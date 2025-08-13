extends Camera2D

var shift_x: float = 0.0
var shift_y: float = 0.0
@onready var Plr = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = Plr.position.x
	position.y = Plr.position.y+70

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if Plr.velocity.y >= 270:
		shift_y = MathFunc.approach(shift_y, 80.0, 1.5)
	elif Plr.velocity.y <= 0:
		shift_y = MathFunc.approach(shift_y, 0.0, 1)

	#if GameOptions.camera_pan != 0:
	#match(GameOptions.camera_pan):
	#case 1: #fixed panning

	# UNCOMMENT THIS IF YOU WANT FIXED PANNING
	#if abs(Plr.velocity.x) > 0 or abs(Plr.velocity.x) > 0 and InputManager.direction == sign(Plr.velocity.x):
	#	shift_x = MathFunc.approach(shift_x, 30.0*Plr.facing_direction, 0.8)
	#elif Plr.velocity.x == 0:
	#	shift_x = MathFunc.approach(shift_x, 0, 0.5)

	#case 2: #smooth panning

	# UNCOMMENT THIS IF YOU WANT SMOOTH PANNING
	#if abs(Plr.velocity.x) > 0 or abs(Plr.velocity.x) > 0 and InputManager.direction == sign(Plr.velocity.x):
	#	shift_x = lerp(shift_x, Plr.velocity.x/5, 0.1)
	#elif Plr.velocity.x == 0:
	#	shift_x = lerp(shift_x, 0.0, 0.1)

	position.x = shift_x
	position.y = shift_y
