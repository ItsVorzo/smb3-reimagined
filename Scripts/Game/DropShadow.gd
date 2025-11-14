extends Node2D

@export var shadow_offset: Vector2 = Vector2(3, 3)
@export var shadow_tint: Color = Color(0, 0, 0, 0.5)

var parent_sprite: Node = null
var shadow_sprite: Node = null
var is_animated: bool = false
var last_animation: String = ""
var last_frames: SpriteFrames = null

func _ready() -> void:
	# Find parent sprite
	parent_sprite = get_parent().get_node_or_null("AnimatedSprite2D")
	if parent_sprite:
		is_animated = true
	else:
		parent_sprite = get_parent().get_node_or_null("Sprite2D")
		if parent_sprite:
			is_animated = false

	if not parent_sprite:
		push_error("DropShadow: Parent has no Sprite2D or AnimatedSprite2D! Hiding shadow.")
		visible = false
		set_process(false)
		return

	# Keep shadow behind parent
	z_as_relative = false
	if is_animated:
		z_index = parent_sprite.z_index - 1
	else:
		z_index = parent_sprite.z_index - 1
	add_to_group("DropShadow")

	# Create the shadow node
	if is_animated:
		var s := AnimatedSprite2D.new()
		s.sprite_frames = parent_sprite.sprite_frames
		s.animation = parent_sprite.animation
		s.frame = parent_sprite.frame
		shadow_sprite = s
	else:
		var s := Sprite2D.new()
		s.texture = parent_sprite.texture
		shadow_sprite = s

	add_child(shadow_sprite)
	shadow_sprite.name = "ShadowSprite"
	shadow_sprite.z_index = z_index

	# Theme and config
	_apply_theme_shadow_color()
	_update_shadow_from_config()
	_set_offset_based_on_owner()

	set_process(true)


func _process(_delta: float) -> void:
	if not is_instance_valid(parent_sprite) or not is_instance_valid(shadow_sprite):
		visible = false
		return

	if is_animated:
		if parent_sprite.animation != last_animation:
			shadow_sprite.play(parent_sprite.animation)
			last_animation = parent_sprite.animation

		shadow_sprite.frame = parent_sprite.frame

		if parent_sprite.sprite_frames != last_frames:
			shadow_sprite.sprite_frames = parent_sprite.sprite_frames
			last_frames = parent_sprite.sprite_frames
	else:
		shadow_sprite.texture = parent_sprite.texture

	shadow_sprite.scale = parent_sprite.scale
	shadow_sprite.flip_h = parent_sprite.flip_h
	shadow_sprite.flip_v = parent_sprite.flip_v
	position = shadow_offset

	if parent_sprite.z_index - 1 != z_index:
		z_index = parent_sprite.z_index - 1
		shadow_sprite.z_index = z_index


func _set_offset_based_on_owner() -> void:
	var owner = get_owner()
	if owner and typeof(owner.scene_file_path) == TYPE_STRING:
		if owner.scene_file_path.ends_with("Scenes/Player/player.tscn"):
			shadow_offset = Vector2(3, -13)
		else:
			shadow_offset = Vector2(3, 3)
	else:
		shadow_offset = Vector2(3, 3)
	position = shadow_offset


func _apply_drop_shadow(state: bool) -> void:
	visible = state


func _update_shadow_from_config() -> void:
	if ConfigManager == null:
		visible = true
		return

	if not ConfigManager.option_indices.has("DropShadows"):
		visible = true
		return

	var idx: int = ConfigManager.option_indices["DropShadows"]
	var raw_val = ConfigManager.option_values["DropShadows"][idx]

	var enabled := false
	if typeof(raw_val) == TYPE_INT:
		enabled = raw_val == 1
	elif typeof(raw_val) == TYPE_STRING:
		var t = raw_val.to_lower()
		enabled = (t == "1" or t == "on" or t == "true")

	visible = enabled


func _apply_theme_shadow_color() -> void:
	var parent_node: Node = get_parent()
	var level_node: Node = null

	while parent_node:
		if "theme" in parent_node:
			level_node = parent_node
			break
		parent_node = parent_node.get_parent()

	if level_node:
		match level_node.theme:
			"Castle":
				shadow_tint = Color(1, 1, 1, 0.5)
			_:
				shadow_tint = Color(0, 0, 0, 0.5)

	if shadow_sprite:
		shadow_sprite.modulate = shadow_tint
