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

	var item = item_scene.instantiate()
	get_tree().current_scene.add_child(item)
	item.global_position = global_position - Vector2(0, 16)

	# Play item pop sound only if item is not coin.tscn
	var scene_path := item_scene.resource_path
	if not scene_path.ends_with("coin.tscn"):
		item_pop_sound.play()

	# Disable the bottom hitbox (still solid on top)
	$CollisionShape2D.disabled = true

func break_block():
	break_sound.play()
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
