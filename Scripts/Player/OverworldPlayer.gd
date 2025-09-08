extends CharacterBody2D

const TILE_SIZE = 32
const SLIDE_SPEED = 120

var is_moving = false
var target_position = Vector2.ZERO

@onready var animation = $AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_timer = $Timer
@onready var move_sound = $MoveSound  # 🔊 Reference to your sound node
var input_device := -1
@export var player_id := 0
var character_index := 0
var character = ["Mario", "Luigi", "Toad", "Toadette"]

func char_idx() -> int:
	return int(SaveManager.runtime_data.get("character_index", 0))
	
@export var pwrup: PowerUps = null
var current_powerup: int = 0
var jump_buffer_timer = 0.12
var coyote_timer = 0.12
var crouching
var skidding = false
var is_super := false
var can_take_damage := true
var is_dead := false

func _ready() -> void:

	SaveManager.start_runtime_from_save(0)
	character_index = char_idx() # Get the current character index
	animated_sprite.sprite_frames = load("res://SpriteFrames/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
	target_position = position
	add_to_group("Overworld")

func _process(delta):
	if not is_moving:

		var input_direction = Vector2(
			int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
			int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		)

		# Prevent diagonal input
		if input_direction.x != 0:
			input_direction.y = 0

		if input_direction != Vector2.ZERO:
			target_position = position + input_direction * TILE_SIZE
			is_moving = true

			if not move_sound.playing:
				SoundManager.play_sfx("MapMove", global_position)
	else:
		position = position.move_toward(target_position, SLIDE_SPEED * delta)
		if position.is_equal_approx(target_position):
			is_moving = false
			position = target_position
