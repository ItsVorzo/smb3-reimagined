class_name EnemyClass
extends CharacterBody2D

# === General enemy info ===
@export var collision: CollisionShape2D = null
@export var hurtbox: Area2D = null
@export var sprite: Node = null
@export var stompbox: Area2D = null
@export var has_custom_stomp := false
@export var can_die_from_fire := true
@export var can_die_from_slide := true
@export var xspd := 30
@export var grav_speed := 400.0

# === Other shit ===
var dead_from_obj := false
var can_stomp := false
var stomped := false
var direction: int
var score_value = 100
var og_spawn_position
var can_respawn := false

# === SUPER IMPORTANT DON'T FORGET THIS ===
func init() -> void:
	og_spawn_position = global_position
	if not is_in_group("Enemies"):
		add_to_group("Enemies")
	if stompbox != null and not stompbox.body_entered.is_connected(stomp_the_enemy):
			stompbox.body_entered.connect(stomp_the_enemy)
	direction = sign(GameManager.nearest_player(global_position).global_position.x - global_position.x)

# === Some SUPER IMPORTANT enemy logic ===
func process(delta: float) -> void:
	# Special case for when enemy is killed by an object
	if dead_from_obj and not stomped:
		if stompbox != null:
			stompbox.monitoring = false
		collision.disabled = true
		hurtbox.monitoring = false
		if sprite: sprite.rotation += 0.3 * direction
		velocity.y += grav_speed * delta
		if not GameManager.is_on_screen(global_position):
			queue_free()

	# Damage the player
	if hurtbox.monitoring:
		for body in hurtbox.get_overlapping_bodies():
			if body.is_in_group("Player"):
				player_interaction(body)

	# NO stomping
	if stompbox == null:
		can_stomp = false
	else:
		can_stomp = true

# === Go back and forth ===
func move_horizontally() -> void:
	if not stomped and not dead_from_obj:
		velocity.x = xspd * direction

func flip_direction() -> void:
	if is_on_wall():
		direction *= -1
		translate(Vector2(1.0 * direction, 0.0)) # Offset, so they don't overlap

# === Give gravity ===
func gravity(delta: float):
	velocity.y += grav_speed * delta

# === Stomp the enemy ===
func stomp_the_enemy(body: Node) -> void:
	if stomped or not can_stomp:
		return
	if not body.is_in_group("Player"):
		return
	if not body.is_on_floor():
		body.bounce_on_enemy()
		SoundManager.play_sfx("Stomp", global_position)
		SaveManager.add_score(score_value)
		if has_custom_stomp:
			on_stomped()
		else:
			die_from_stomp()

# == Custom stomp function ===
# Basically if you want a custom action
# when you stomp an enemy, check the has_custom_stomp box
# and then write something in this function
# if the box isn't checked it will fallback
# to the default stomping (die_from_stomp())
func on_stomped() -> void:
	pass

# === The default stomp death ===
func die_from_stomp() -> void:
	if stompbox: 
		stomped = true
		dead_from_obj = false
	velocity = Vector2.ZERO

	# disable all collisions
	collision.set_deferred("disabled", true)
	stompbox.set_deferred("monitoring", false)
	hurtbox.monitoring = false
	await get_tree().create_timer(0.5).timeout
	queue_free()

# === Die from an object (it could be anything) ===
func die_from_obj(dir := 1, spd := 130) -> void:
	SoundManager.play_sfx("Kick", global_position)
	SaveManager.add_score(score_value)
	dead_from_obj = true
	direction = dir
	velocity.x = spd * direction
	velocity.y = -160

# === Damage the player... or the player damages YOU! ===
func player_interaction(body: Node) -> void:
	if body.state_machine.state.name == "Slide" and can_die_from_slide:
		die_from_obj(body.velocity_direction)
	elif body.can_take_damage:
		body.damage()

# === Reset any enemy variable you want with this function ===
func reset_enemy() -> void:
	pass
