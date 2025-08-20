extends Node

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Process inputs
# Whenever you want to call an input you must call it as so: InputManager.A/B/left/right...
func _process(_delta: float) -> void:
	if !input_disabled:
		if !action_disabled:
			A = Input.is_action_pressed("A")
			B = Input.is_action_pressed("B")
			Apress = Input.is_action_just_pressed("A")
			Bpress = Input.is_action_just_pressed("B")
			Areleased = Input.is_action_just_released("A")
			Breleased = Input.is_action_just_released("B")
		if !direction_disabled:
			up = Input.is_action_just_pressed("up")
			down = Input.is_action_pressed("down")
			up_press = Input.is_action_just_pressed("up")
			down_press = Input.is_action_just_pressed("down")
			up_released = Input.is_action_just_released("up")
			down_released = Input.is_action_just_released("down")
			direction = sign(Input.get_axis("left", "right"))
			if !x_direction_disabled:
				left = Input.is_action_pressed("left")
				right = Input.is_action_pressed("up")
				left_press = Input.is_action_just_pressed("left")
				right_press = Input.is_action_just_pressed("right")
				left_released = Input.is_action_just_released("left")
				right_released = Input.is_action_just_released("right")
