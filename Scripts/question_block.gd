extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bounce_anim: AnimationPlayer = $AnimationPlayer
@onready var hit_sound: AudioStreamPlayer2D = $Hit
@onready var item_pop_sound: AudioStreamPlayer2D = $ItemPop

@export var item_scene: PackedScene  # Drag in Coin.tscn, Mushroom.tscn, etc.

var used := false

func _ready():
	sprite.play("full")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if used or not body.is_in_group("Player"):
		return

	if body.global_position.y > global_position.y + 5:
		activate_block()

func activate_block():
	used = true
	hit_sound.play()
	bounce_anim.play("bounce")

	await get_tree().create_timer(0.15).timeout  # Item appears mid-bounce

	sprite.play("empty")

	if item_scene:
		var item = item_scene.instantiate()
		get_tree().current_scene.add_child(item)
		item.global_position = global_position - Vector2(0, 16)

		# Only play sound if not coin.tscn
		var scene_path := item_scene.resource_path
		if not scene_path.ends_with("coin.tscn"):
			item_pop_sound.play()

	# Disable the bottom hitbox to avoid re-use
	$CollisionShape2D.disabled = true
