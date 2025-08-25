extends CharacterBody2D

const TILE_SIZE = 32
const SLIDE_SPEED = 120

var is_moving = false
var target_position = Vector2.ZERO

@onready var animation = $AnimatedSprite2D
@onready var animation_timer = $Timer
@onready var move_sound = $MoveSound  # 🔊 Reference to your sound node

func _ready():
	if PlayerManager.player_data:
		PlayerManager.player_data.erase(1)
		PlayerManager.player_data.erase(2)
		PlayerManager.player_data.erase(3)
	target_position = position
	add_to_group("Overworld")

func _on_animation_timer_timeout():
	animation.play("down")

func _process(delta):
	if not is_moving:
		animation.play("down")
		var input_direction = Vector2.ZERO

		if InputManager.right_press:
			input_direction.x = 1
			animation.play("side")
			animation.flip_h = true
		elif InputManager.left_press:
			input_direction.x = -1
			animation.play("side")
			animation.flip_h = false
		elif InputManager.up_press:
			input_direction.y = -1
			animation.play("up")
		elif InputManager.down_press:
			input_direction.y = 1
			animation.play("down")

		if input_direction != Vector2.ZERO:
			target_position = position + input_direction * TILE_SIZE
			is_moving = true

			if not move_sound.playing:
				SoundManager.play_sfx("MapMove", global_position)  # 🔊 Play movement sound
	else:
		position = position.move_toward(target_position, SLIDE_SPEED * delta)
		if position.is_equal_approx(target_position):
			is_moving = false
			position = target_position
