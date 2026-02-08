extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var dropshadow: AnimatedSprite2D = $DropShadow

var was_brick := false
var from_block := false
var collected := false
var default_z_index := 0


func _ready() -> void:
	GameManager.p_switch_activated.connect(_on_p_switch)
	GameManager.p_switch_expired.connect(_on_p_switch_expired)
	if from_block:
		_pop_animation()
		anim_sprite.play("item_box", 2)
	else:
		anim_sprite.play("collectable")
	connect("body_entered", _on_body_entered)

func _physics_process(_delta: float) -> void:
	if not from_block:
		z_index = default_z_index

func _on_body_entered(body: Node) -> void:
	if collected or not body.is_in_group("Player"):
		return

	collected = true
	_add_coin_to_hud()
	SoundManager.play_sfx("Coin", global_position)

	# Hide immediately (so player can't touch again)
	anim_sprite.visible = false
	dropshadow.visible = false
	collision.set_deferred("monitoring", false)

	# Remove once sound finishes (~0.88s)
	await get_tree().create_timer(0.88).timeout
	queue_free()

# Replace this coin with a brick if it wasn't already a brick when p switch is on
func _on_p_switch():
	if collected or was_brick:
		return
	var brick = load("res://Scenes/Blocks/BrickBlock.tscn").instantiate()
	brick.was_coin = true
	brick.global_position = global_position
	get_parent().call_deferred("add_child", brick)
	queue_free()

func _on_p_switch_expired():
	if collected:
		return
	var brick = load("res://Scenes/Blocks/BrickBlock.tscn").instantiate()
	brick.global_position = global_position
	get_parent().call_deferred("add_child", brick)
	queue_free()

func _pop_animation() -> void:
	# Up + Down animation matching the coin sound length (0.88s)
	var tween = create_tween()
	var start_y = global_position.y
	var peak_y = start_y - 48  # ↑ 48px jump
	tween.tween_property(self, "global_position:y", peak_y, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", start_y, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_add_coin_to_hud()
	tween.tween_callback(queue_free)


func _add_coin_to_hud() -> void:
	var coins = SaveManager.runtime_data.get("coins", 0)
	coins += 1
	SaveManager.runtime_data["coins"] = coins
	GameManager.coins = coins

	if SaveManager.hud:
		SaveManager.hud.update_labels()
