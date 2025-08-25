extends Node

var player: Player
var device_n = -1 # Device number/id (defaults to keyboard/p1)

# === Inputs ===
var A
var B
var left
var up
var down
var right
var Apress
var Bpress
var left_press
var up_press
var down_press
var right_press
var Areleased
var Breleased
var left_released
var up_released
var down_released
var right_released
var direction

# === Flags ===
var input_disabled = false
var direction_disabled = false
var x_direction_disabled = false
var action_disabled = false

# Process inputs
# Whenever you want to call an input you must call it as so: InputManager.A/B/left/right...
func _process(_delta: float) -> void:
	if device_n == null:
		assert(device_n != null, "No input device detected!! Happens if device_n is null")
		return

	if !input_disabled:
		if !action_disabled:
			A = MultiplayerInput.is_action_pressed(device_n, "A")
			B = MultiplayerInput.is_action_pressed(device_n, "B")
			Apress = MultiplayerInput.is_action_just_pressed(device_n, "A")
			Bpress = MultiplayerInput.is_action_just_pressed(device_n, "B")
			Areleased = MultiplayerInput.is_action_just_released(device_n, "A")
			Breleased = MultiplayerInput.is_action_just_released(device_n, "B")
		if !direction_disabled:
			up = MultiplayerInput.is_action_just_pressed(device_n, "up")
			down = MultiplayerInput.is_action_pressed(device_n, "down")
			up_press = MultiplayerInput.is_action_just_pressed(device_n, "up")
			down_press = MultiplayerInput.is_action_just_pressed(device_n, "down")
			up_released = MultiplayerInput.is_action_just_released(device_n, "up")
			down_released = MultiplayerInput.is_action_just_released(device_n, "down")
			direction = sign(MultiplayerInput.get_axis(device_n, "left", "right"))
			if !x_direction_disabled:
				left = MultiplayerInput.is_action_pressed(device_n, "left")
				right = MultiplayerInput.is_action_pressed(device_n, "up")
				left_press = MultiplayerInput.is_action_just_pressed(device_n, "left")
				right_press = MultiplayerInput.is_action_just_pressed(device_n, "right")
				left_released = MultiplayerInput.is_action_just_released(device_n, "left")
				right_released = MultiplayerInput.is_action_just_released(device_n, "right")
