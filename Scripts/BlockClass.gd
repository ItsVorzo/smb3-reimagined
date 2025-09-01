class_name block
extends CharacterBody2D

# === Block info ===
@export var hitbox: Area2D = null
@export var sprite: Node = null
@export var item: PackedScene = null
var item_scene: Node
var coin_scene = load("res://Scenes/Items/coin.tscn")

# === Block position/states ===
var original_y_pos: float
var yspd := 0.0
var gravity := 1500.0
var is_activated := false
var is_used := false

func _ready() -> void:
	original_y_pos = sprite.global_position.y
	hitbox.body_entered.connect(activate)

# === Processing ===
func _physics_process(delta: float) -> void:

	# Stop the block's function when it's already used
	if not is_activated or is_used:
		return

	# Makes the sprite bounce on hit
	sprite.global_position.y += yspd * delta

	# Changes the sprite velocity
	yspd += gravity * delta
	# Snaps the sprite position to the og one
	if sprite.global_position.y > original_y_pos:
		sprite.global_position.y = original_y_pos
		is_activated = false
		is_used = true

# === Activate the block
func activate(body: Node):
	if body.is_in_group("Player") and body.velocity.x >= -10 and not is_activated and not is_used:
		sprite.play("Activated")
		is_activated = true
		yspd = -140.0
		if item == null:
			SoundManager.play_sfx("Coin", self.global_position)
			item_scene = coin_scene.instantiate()
			spawn_item()
		else:
			SoundManager.play_sfx("ItemPop", self.global_position)
			item_scene = item.instantiate()
			spawn_item()

func spawn_item():
	item_scene.default_z_index = item_scene.z_index
	item_scene.from_block = true
	item_scene.global_position.x = self.global_position.x
	item_scene.global_position.y = self.global_position.y - 6
	get_tree().current_scene.add_child(item_scene)
	item_scene.z_index = self.z_index - 1
