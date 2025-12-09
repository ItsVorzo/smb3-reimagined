class_name BlockClass
extends StaticBody2D

@export var hitbox: Area2D = null
@export var sidebox: Area2D = null
@export var top_interaction: Area2D = null
@export var sprite: Node = null
@export var item: PackedScene = null
var item_scene: Node
const coin_scene = preload("res://Scenes/Items/Coin.tscn")
const mushroom_scene = preload("res://Scenes/Items/Mushroom.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Blocks")
	hitbox.body_entered.connect(activation_condition)
	sidebox.body_entered.connect(activation_condition)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func activation_condition(_body: Node):
	pass

func activate(_body: Node) -> void:
	pass

func spawn_item() -> void:
	pass

func block_top_interaction(_body: Node) -> void:
	pass
