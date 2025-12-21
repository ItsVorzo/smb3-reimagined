class_name EnemyClass
extends CharacterBody2D

# === General enemy info ===
@export var collision: CollisionShape2D = null
@export var hitbox: Area2D = null
@export var can_stomp := true
@export var stomp_tolerance := 4
@export var sprite: Node = null
@export var can_die_from_fire := true
@export var can_die_from_slide := true
@export var score_value = 100
@export var xspd := 30
@export var grav_speed := 400.0

# === Other shit ===
var dead_from_obj := false
var stomped := false
var direction: int
var og_spawn_position
var can_respawn := false

# === SUPER IMPORTANT DON'T FORGET THIS ===
func _ready() -> void:
	og_spawn_position = global_position
	if not is_in_group("Enemies"):
		add_to_group("Enemies")
	if not hitbox.is_connected("area_entered", area_entered):
		hitbox.area_entered.connect(area_entered)
	direction = sign(GameManager.nearest_player(global_position).global_position.x - global_position.x)

func player_above(player: Player) -> bool:
	return player.global_position.y + stomp_tolerance < global_position.y and not player.state_machine.state.name == "Slide"

# === Some SUPER IMPORTANT enemy logic ===
func process(delta: float) -> void:
	#print(player_above(), "  ", GameManager.first_player().global_position.y, "   ", hitbox.global_position.y)
	# Special case for when enemy is killed by an object
	if dead_from_obj and not stomped:
		collision.disabled = true
		hitbox.monitoring = false
		if sprite: sprite.rotation += 0.3 * direction
		velocity.y += grav_speed * delta
		if not GameManager.is_on_screen(global_position):
			queue_free()

	# Damage the player
	if hitbox.monitoring:
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("Player") and not player_above(body):
				enemy_interaction(body)

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

func area_entered(area: Area2D) -> void:
	if area.owner is Player:
		print(area.global_position.y)
		player_interaction(area.owner)

# === Stomp the enemy ===
func player_interaction(player: Player) -> void:
	print("i'm in at:  ", player.global_position.y)
	if stomped or not can_stomp:
		return
	print(player_above(player), "     hit position.y:  ", player.global_position.y + 4, "  intended hit:   ", global_position.y)
	if player_above(player):
		player.bounce_on_enemy()
		SoundManager.play_sfx("Stomp", global_position)
		SaveManager.add_score(score_value)
		on_stomped()
	else:
		enemy_interaction(player)

# == Stomp function ===
# Do something when you get STOMPED!!!
func on_stomped() -> void:
	pass

# === The default stomp death ===
# Place this in on_stomped() if you want to use it
func die_from_stomp() -> void:
	if can_stomp:
		stomped = true
		dead_from_obj = false
	velocity = Vector2.ZERO

	# disable all collisions
	collision.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	await get_tree().create_timer(0.5).timeout
	queue_free()

# === Override this function to insert more interactions ===
func tail_interaction(body: Node):
	die_from_obj(-sign(body.global_position.x - global_position.x), 60.0)

# === Die from an object (it could be anything) ===
func die_from_obj(dir := 1, spd := 130) -> void:
	SoundManager.play_sfx("Kick", global_position)
	SaveManager.add_score(score_value)
	dead_from_obj = true
	direction = dir
	velocity.x = spd * direction
	velocity.y = -160

# === Damage the player... or the player damages YOU! ===
func enemy_interaction(player: Player) -> void:
	if player.state_machine.state.name == "Slide" and can_die_from_slide:
		die_from_obj(player.velocity_direction)
	elif player.can_take_damage:
		player.damage()

# === Reset any enemy variable you want with this function ===
func reset_enemy() -> void:
	pass
