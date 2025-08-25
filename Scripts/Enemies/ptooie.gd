extends EnemyClass  # EnemyClass extends CharacterBody2D

@export var ball_scene: PackedScene = preload("res://Scenes/Enemies/Ball.tscn")

# Movement variables
var xspd := -30.0
var gravity := 1000.0
var max_fall_speed := 2000.0
const BALL_OFFSET_Y := -60.0 


enum State { WALKING, PAUSING }
var state := State.WALKING
@export var walk_duration := 2.0
@export var pause_duration := 1.0
var state_timer := 0.0


var wobble_offset := 0.0
var wobble_speed := 10.0
var wobble_amplitude := 4.0


var ball_instance: Node2D

func _ready() -> void:
	set_signals()
	spawn_ball_above()
	state = State.WALKING
	state_timer = walk_duration

func _physics_process(delta: float) -> void:
	process()

	if stomped:
		return


	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall_speed)


	state_timer -= delta
	match state:
		State.WALKING:
			velocity.x = xspd
			move_and_slide()

			
			if is_on_wall():
				xspd *= -1
				flip_sprite()

			
			if state_timer <= 0:
				state = State.PAUSING
				state_timer = pause_duration
				velocity.x = 0  
				
		State.PAUSING:

			wobble_motion(delta)
			move_and_slide()


			if state_timer <= 0:
				state = State.WALKING
				state_timer = walk_duration
				velocity.x = xspd

	
	if ball_instance:
		ball_instance.global_position = global_position + Vector2(0, BALL_OFFSET_Y)

func wobble_motion(delta: float) -> void:
	wobble_offset += delta * wobble_speed
	var offset_x = sin(wobble_offset) * wobble_amplitude
	global_position.x += offset_x * delta  

func spawn_ball_above() -> void:
	if ball_instance:
		return  
	ball_instance = ball_scene.instantiate()
	get_parent().add_child(ball_instance)
	ball_instance.global_position = global_position + Vector2(0, BALL_OFFSET_Y)

func flip_sprite() -> void:
	var sprite = get_node_or_null("Sprite")
	if sprite:
		sprite.scale.x *= -1
