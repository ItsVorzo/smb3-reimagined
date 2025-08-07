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

func _on_body_entered(body: Node) -> void:
	if used or not body.is_in_group("Player"):
		return

	if body.global_position.y > global_position.y + 5:
		activate_block()

func activate_block():
	used = true
	hit_sound.play()
	bounce_anim.play("bounce")

	await get_tree().create_timer(0.15).timeout

	sprite.play("empty")

	if item_scene:
		var item_holder := Node2D.new()
		item_holder.position = global_position
		item_holder.z_index = z_index - 1
		get_tree().current_scene.add_child(item_holder)

		var item = item_scene.instantiate()
		item_holder.add_child(item)
		item.position = Vector2.ZERO

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

		var scene_path := item_scene.resource_path
		if not scene_path.ends_with("coin.tscn"):
			item_pop_sound.play()

	$CollisionShape2D.disabled = true
