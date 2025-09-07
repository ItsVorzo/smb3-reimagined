extends EnemyClass  # EnemyClass extends CharacterBody2D

var max_fall_speed := 2000.0

# Bobbing parameters
var bob_speed := 6.0
var bob_amplitude := 4.0
var bob_time := 0.0

func _ready() -> void:
	init()
	_show_wings(true)

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()
	sprite.scale.x = direction

	if stomped:
		$Sprite.play("squish")
		return

	# Apply gravity
	gravity(delta)
	velocity.y = min(velocity.y, max_fall_speed)

	# Horizontal movement
	velocity.x = xspd

	move_and_slide()

	flip_direction()

	# Bobbing effect (purely visual)
	bob_time += delta * bob_speed
	var bob_offset = sin(bob_time) * bob_amplitude

	# Apply bobbing to Sprite and wings' position (local position)
	for part_name in ["Sprite", "Wings", "Wings2"]:
		var part = get_node_or_null(part_name)
		if part:
			var pos = part.position
			pos.y = bob_offset
			part.position = pos

func _show_wings(visible: bool) -> void:
	for wing_name in ["Wings", "Wings2"]:
		var wing = get_node_or_null(wing_name)
		if wing:
			wing.visible = visible
