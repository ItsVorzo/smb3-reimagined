extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bounce_anim: AnimationPlayer = $AnimationPlayer
@onready var hit_sound: AudioStreamPlayer2D = $Hit
@onready var item_pop_sound: AudioStreamPlayer2D = $ItemPop

@export var item_scene: PackedScene

var used := false

func _ready():
	sprite.play("full")
	connect("body_entered", _on_body_entered)

	var theme_manager = get_tree().get_first_node_in_group("ThemeManager")
	if theme_manager:
		theme_manager.theme_changed.connect(apply_theme)
		apply_theme(theme_manager.theme)

func _on_body_entered(body: Node) -> void:
	if used or not body.is_in_group("Player"):
		return

	if body.global_position.y > global_position.y + 5:
		activate_block()

func activate_block():
	used = true
	hit_sound.play()
	bounce_anim.play("bounce")

	# Short delay for bounce animation
	await get_tree().create_timer(0.15).timeout

	sprite.play("empty")

	if item_scene:
		var item_holder := Node2D.new()
		# Place holder slightly above the block
		item_holder.position = global_position - Vector2(0, 16)
		item_holder.z_index = z_index - 1
		get_tree().current_scene.add_child(item_holder)

		var item = item_scene.instantiate()
		# Mark coin as from block if it supports it
		if "from_block" in item:
			item.from_block = true

		item_holder.add_child(item)

		var scene_path := item_scene.resource_path

		if scene_path.ends_with("coin.tscn"):
			# For coins: no tween, just place above the block
			item_holder.remove_child(item)
			get_tree().current_scene.add_child(item)
			item.global_position = item_holder.global_position
			item.z_index = z_index - 1
			item_holder.queue_free()
			item_pop_sound.play()  # optional for coin pop sound
		else:
			# For other items: upward pop animation
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(item_holder, "position", global_position - Vector2(0, 24), 0.5)
			tween.tween_callback(func():
				item_holder.remove_child(item)
				get_tree().current_scene.add_child(item)
				item.global_position = item_holder.global_position
				item.z_index = z_index - 1
				item_holder.queue_free()
			)
			item_pop_sound.play()

	$CollisionShape2D.disabled = true


func apply_theme(theme: String):
	var tex_path = "res://Sprites/Blocks/General%s.png" % theme
	var new_texture = load(tex_path)
	if not new_texture:
		push_warning("Theme texture not found at %s" % tex_path)
		return

	var frames = sprite.sprite_frames
	for anim_name in frames.get_animation_names():
		var frame_count = frames.get_frame_count(anim_name)
		for i in range(frame_count):
			var frame_tex = frames.get_frame_texture(anim_name, i)
			if frame_tex is AtlasTexture:
				# Keep same rect, swap atlas
				var rect = frame_tex.region
				var atlas = AtlasTexture.new()
				atlas.atlas = new_texture
				atlas.region = rect
				frames.set_frame(anim_name, i, atlas)
