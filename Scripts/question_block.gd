extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var bump: AudioStreamPlayer2D = $Bump
@onready var item_spawn_pos: Marker2D = $ItemSpawnPosition

enum ItemType {NONE, COIN, MUSHROOM, LIFEUP, LEAF, TANOOKI, HAMMER}

@export var item_to_spawn: ItemType = ItemType.COIN
var is_used = false

func _ready() -> void:
	if not is_used:
		sprite.play("full")

func hit_from_below(body):
	if is_used:
		return
	is_used = true
	bump.play()
	anim.play("bounce")
	spawn_item()
	sprite.play("empty")
	
func spawn_item():
	print("Spawn point:",item_spawn_pos.global_position)
	match item_to_spawn:
		ItemType.COIN:
			var coin_scene = preload("res://Scenes/coin.tscn")
			var coin = coin_scene.instantiate()
			
			if coin:
				coin.global_position = item_spawn_pos.global_position + Vector2(0, -8)
				get_parent().add_child(coin)
		_:
			pass # No Item
