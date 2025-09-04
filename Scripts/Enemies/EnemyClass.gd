class_name EnemyClass
extends CharacterBody2D

@export var collision: CollisionShape2D = null
@export var hurtbox: Area2D = null
@export var stompbox: Area2D = null
@export var sprite: Node = null
var dead_from_obj := false
var can_stomp := false
var stomped := false
var score_value = 100

# === Important signals ===
func set_signals() -> void:
	add_to_group("Enemies")
	hurtbox.body_entered.connect(_on_hurtbox_touch)
	if stompbox != null: stompbox.body_entered.connect(_on_head_stomp)

# === Knock off physics process ===
func process(delta: float) -> void:
	# Special case for when enemy is killed by an object
	if dead_from_obj:
		if stompbox != null:
			stompbox.monitoring = false
		collision.disabled = true
		hurtbox.monitoring = false
		if sprite: sprite.rotation += 0.4 * sign(velocity.x)

	# NO stomping
	if stompbox == null:
		can_stomp = false
	else:
		can_stomp = true

# === Stomp the enemy ===
func _on_head_stomp(body: Node) -> void:
	if stomped or not can_stomp:
		return
	if not body.is_in_group("Player"):
		return
	if body.velocity.y > 0:
		if body.has_method("bounce_on_enemy"):
			body.bounce_on_enemy()
		SaveManager.runtime_data["score"] = SaveManager.runtime_data.get("score", 0) + score_value
		if SaveManager.hud and SaveManager.hud.has_method("update_labels"):
			SaveManager.hud.update_labels()
		_die()

# === Enemy's dead ===
func _die() -> void:
	if stompbox: stomped = true
	velocity = Vector2.ZERO

	# disable all collisions
	collision.disabled = true
	stompbox.monitoring = false
	hurtbox.monitoring = false
	await get_tree().create_timer(0.5).timeout
	queue_free()

# === Damage the player ===
func _on_hurtbox_touch(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("damage") and body.can_take_damage:
		body.damage()
