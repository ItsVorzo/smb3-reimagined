class_name block
extends CharacterBody2D

# === Block info ===
@export var hitbox: Area2D = null
@export var sidebox: Area2D = null
@onready var top_interaction: Area2D = $TopInteraction
@export var sprite: Node = null
@export var item: PackedScene = null
var item_scene: Node
const coin_scene = preload("res://Scenes/Items/coin.tscn")
const mushroom_scene = preload("res://Scenes/Items/Mushroom.tscn")

# === Block position/states ===
var original_y_pos: float
var yspd := 0.0
var gravity := 1500.0
var is_activated := false
var is_used := false

# === Set some important stuff
func _ready() -> void:
	add_to_group("Blocks")
	original_y_pos = sprite.global_position.y
	hitbox.body_entered.connect(activate)
	sidebox.body_entered.connect(activate)

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
	if (body.is_in_group("Player") or body.is_in_group("Shell") and body.grab.is_kicked) and not is_activated and not is_used:
		sprite.play("Activated")
		is_activated = true
		yspd = -140.0

		# Interact with other objects on top
		for obj in top_interaction.get_overlapping_bodies():
			if obj != null:
				block_top_interaction(obj)

		# If there's nothing in the block, give a coin
		if item == null:
			SoundManager.play_sfx("Coin", self.global_position)
			item_scene = coin_scene.instantiate()
			spawn_item(body)
		# Else give a mushroom if you're small/there's a mushroom
		else:
			for p in get_tree().get_nodes_in_group("Player"):
				if p.pwrup.tier < 1 or item == mushroom_scene:
					SoundManager.play_sfx("ItemPop", self.global_position)
					item_scene = mushroom_scene.instantiate()
					spawn_item(body)
				# Cooler powerup
				else:
					SoundManager.play_sfx("ItemPop", self.global_position)
					item_scene = item.instantiate()
					spawn_item(body)

# Item pop sound effect
func spawn_item(body: Node):
	item_scene.default_z_index = item_scene.z_index # Get the original z index
	item_scene.from_block = true 
	item_scene.global_position.x = self.global_position.x
	item_scene.global_position.y = self.global_position.y - 6
	get_tree().current_scene.call_deferred("add_child", item_scene) # Add it to the level tree
	item_scene.z_index = self.z_index - 1 # Draw it behind the block
	# If the item has got a direction variable, make it go to the opposite direction
	if item_scene.get("direction") != null:
		item_scene.direction = -sign(body.global_position.x - self.global_position.x)

func block_top_interaction(body):
	if body.is_in_group("Enemies"):
		body.dead_from_obj(body.direction)
	if body.is_in_group("Shell"):
		body.die(body.direction, 60)
