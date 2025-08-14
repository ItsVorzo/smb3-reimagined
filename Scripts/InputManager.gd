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
var direction
var any

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
		if !direction_disabled:
			up = Input.is_action_just_pressed("up")
			down = Input.is_action_pressed("down")
			up_press = Input.is_action_just_pressed("up")
			down_press = Input.is_action_just_pressed("down")
			direction = sign(Input.get_axis("left", "right"))
			if !x_direction_disabled:
				left = Input.is_action_pressed("left")
				right = Input.is_action_pressed("up")
				left_press = Input.is_action_just_pressed("left")
				right_press = Input.is_action_just_pressed("right")
		any = Apress or Bpress or left_press or up_press or down_press or right_press
