extends BlockClass

# === Block position/states ===
var original_y_pos: float
var yspd := 0.0
var gravity := 1500.0
var is_activated := false
var is_used := false
var brick_debris_scene = preload("res://Scenes/Blocks/BrickDebris.tscn")

func _ready() -> void:
	super._ready()
	original_y_pos = sprite.global_position.y

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
		if item != null:
			is_used = true

# === Activate the block
func activate(body: Node) -> void:
	if (body.is_in_group("Player") or body.is_in_group("Shell") and body.grab.is_kicked) and not is_activated and not is_used:
		if item != null:
			sprite.play("Activated")
		is_activated = true
		yspd = -140.0

		# Interact with other objects on top
		for obj in top_interaction.get_overlapping_bodies():
			if obj != null:
				block_top_interaction(obj)

		if item == null:
			if body.is_in_group("Player") and body.pwrup.name == "Big" or body.is_in_group("Shell"):
				destroy()
			else:
				pass
		elif item == coin_scene:
			SoundManager.play_sfx("Coin", self.global_position)
			item_scene = coin_scene.instantiate()
			spawn_item()
		# Else give a mushroom if you're small/there's a mushroom
		else:
			for p in GameManager.get_players():
				if p.pwrup.tier < 1 or item == mushroom_scene:
					SoundManager.play_sfx("ItemPop", self.global_position)
					item_scene = mushroom_scene.instantiate()
					spawn_item()
				# Cooler powerup
				else:
					SoundManager.play_sfx("ItemPop", self.global_position)
					item_scene = item.instantiate()
					spawn_item()

# Item pop sound effect
func spawn_item() -> void:
	item_scene.default_z_index = item_scene.z_index # Get the original z index
	item_scene.from_block = true 
	item_scene.global_position.x = self.global_position.x
	item_scene.global_position.y = self.global_position.y - 6
	get_tree().current_scene.call_deferred("add_child", item_scene) # Add it to the level tree
	item_scene.z_index = self.z_index - 1 # Draw it behind the block
	# If the item has got a direction variable, make it go to the opposite direction
	if item_scene.get("direction") != null:
		item_scene.direction = -sign(GameManager.nearest_player(global_position).global_position.x - self.global_position.x)

func block_top_interaction(body) -> void:
	if body.is_in_group("Enemies"):
		body.dead_from_obj(body.direction, 60)
	if body.is_in_group("Shell"):
		body.die(body.direction, 60)

func destroy() -> void:
	SaveManager.add_score(100)
	SoundManager.play_sfx("Break", global_position)
	for i in range(4):
		var part = brick_debris_scene.instantiate()
		get_parent().add_child(part)

		match i:
			0:
				part.global_position = Vector2(global_position.x - 4, global_position.y + 4)
				part.direction = -1
				part.jump_speed = -220.0
				part.velocity.y = part.jump_speed
			1:
				part.global_position = Vector2(global_position.x - 4, global_position.y - 4)
				part.direction = -1
				part.jump_speed = -330.0
				part.velocity.y = part.jump_speed
			2:
				part.global_position = Vector2(global_position.x + 4, global_position.y + 4)
				part.direction = 1
				part.jump_speed = -220.0
				part.velocity.y = part.jump_speed
			3:
				part.global_position = Vector2(global_position.x + 4, global_position.y - 4)
				part.direction = 1
				part.jump_speed = -330.0
				part.velocity.y = part.jump_speed
	call_deferred("queue_free")
