extends CharacterBody2D

const TILE_SIZE = 32
const SLIDE_SPEED = 120

var is_moving = false
var target_position = Vector2.ZERO

@onready var animation = $AnimatedSprite2D
@onready var animation_timer = $Timer
@onready var move_sound = $MoveSound  # 🔊 Reference to your sound node

func _ready():
	target_position = position
	add_to_group("Overworld")

func _on_animation_timer_timeout():
	animation.play("down")

func _process(delta):
	if not is_moving:
		animation.play("down")
		var input_direction = Vector2.ZERO

		if Input.is_action_just_pressed("ui_right"):
			input_direction.x = 1
			animation.play("side")
			animation.flip_h = true
		elif Input.is_action_just_pressed("ui_left"):
			input_direction.x = -1
			animation.play("side")
			animation.flip_h = false
		elif Input.is_action_just_pressed("ui_up"):
			input_direction.y = -1
			animation.play("up")
		elif Input.is_action_just_pressed("ui_down"):
			input_direction.y = 1
			animation.play("down")

		if input_direction != Vector2.ZERO:
			target_position = position + input_direction * TILE_SIZE
			is_moving = true

			if not move_sound.playing:
				move_sound.play()  # 🔊 Play movement sound
	else:
		position = position.move_toward(target_position, SLIDE_SPEED * delta)
		if position.is_equal_approx(target_position):
			is_moving = false
			position = target_position
