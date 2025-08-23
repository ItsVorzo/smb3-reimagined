extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bounce_anim: AnimationPlayer = $AnimationPlayer
@onready var hit_sound: AudioStreamPlayer2D = $Hit
@onready var break_sound: AudioStreamPlayer2D = $Break
@onready var item_pop_sound: AudioStreamPlayer2D = $ItemPop

@export var debris_scene: PackedScene
@export var item_scene: PackedScene
@export var is_item_block: bool = false

var used := false

func _ready():
	sprite.play("idle")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if used:
		return
	if not body.is_in_group("Player"):
		return
	if body.global_position.y > global_position.y + 5:
		activate_block()

func activate_block():
	used = true

	if is_item_block and item_scene:
		handle_item_block()
	else:
		break_block()

func handle_item_block():
	hit_sound.play()
	bounce_anim.play("bounce")

	await get_tree().create_timer(0.15).timeout

	sprite.play("empty")

	# Create a temporary holder for animation
	var item_holder := Node2D.new()
	item_holder.position = global_position
	item_holder.z_index = z_index - 1
	get_tree().current_scene.add_child(item_holder)

	# Instance the item and add to the holder
	var item = item_scene.instantiate()
	item_holder.add_child(item)
	item.position = Vector2.ZERO  # Centered inside the holder

	# Tween the holder upward
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(item_holder, "position", global_position - Vector2(0, 16), 0.5)
	
	tween.tween_callback(func():
		item_holder.remove_child(item)
		get_tree().current_scene.add_child(item)
		item.global_position = item_holder.global_position
		item.z_index = z_index - 1
		item_holder.queue_free()
	)

	# Play sound if it's not a coin
	var scene_path := item_scene.resource_path
	if not scene_path.ends_with("coin.tscn"):
		SoundManager.play_sfx("ItemPop")

	# Disable the bottom hitbox
	$CollisionShape2D.disabled = true
func break_block():
	var current_time = Time.get_ticks_usec() / 1000000.0

	if current_time - GlobalAudio.last_break_sound_time > GlobalAudio.BREAK_SOUND_COOLDOWN:
		SoundManager.play_sfx("Break")
		GlobalAudio.last_break_sound_time = current_time

	sprite.visible = false
	$StaticBody2D/CollisionShape2D.disabled = true
	$CollisionShape2D.disabled = true

	for i in range(4):
		var debris = debris_scene.instantiate()
		get_tree().current_scene.add_child(debris)
		debris.global_position = global_position
		debris.launch(i)

	await get_tree().create_timer(0.5).timeout
	queue_free()

func _reset_break_sound_flag():
	GlobalAudio.break_sound_played = false

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
