extends CharacterBody2D

@onready var sprite := $Sprite2D
@onready var collision := $Collision
@onready var pickup_area := $Area2D
var from_block := false
var direction := 1
var xspd = 50.0
var gravity := 500.0
var target_y
var default_z_index := 0

func _ready() -> void:
	target_y = self.global_position.y - 10
	pickup_area.body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not from_block:
		z_index = default_z_index
		collision.disabled = false
		velocity.x = xspd * direction
		if not is_on_floor(): velocity.y += gravity * delta
	else:
		collision.disabled = true
		if global_position.y >= target_y:
			global_position.y -= 0.4
		else:
			from_block = false

	move_and_slide()

	if is_on_wall():
		direction *= -1

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	# Add a life
	SoundManager.play_sfx("1UP", body.global_position)
	if SaveManager.hud:
		SaveManager.hud.update_labels()
	SaveManager.add_life(1)

	# Vanish
	queue_free()
	return
