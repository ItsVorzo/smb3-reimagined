extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var from_block: bool = false
var collected := false


func _ready() -> void:
	if from_block:
		# Coin from Question Block
		anim_sprite.play("item_box")
		coin_sound.play()
		_add_coin_to_hud()
		_pop_animation()
	else:
		# Normal placed coin
		anim_sprite.play("collectable")
		collision.disabled = false
		connect("body_entered", _on_body_entered)


func _on_body_entered(body: Node) -> void:
	if collected or not body.is_in_group("Player"):
		return

	collected = true
	_add_coin_to_hud()
	SoundManager.play_sfx("Coin", global_position)

	# Hide immediately (so player can't touch again)
	anim_sprite.visible = false
	collision.disabled = true

	# Remove once sound finishes (~0.88s)
	await get_tree().create_timer(0.88).timeout
	queue_free()


func _pop_animation() -> void:
	# Up + Down animation matching the coin sound length (0.88s)
	var tween = create_tween()
	var start_y = global_position.y
	var peak_y = start_y - 48  # ↑ 48px jump
	tween.tween_property(self, "global_position:y", peak_y, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", start_y, 0.44).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)


func _add_coin_to_hud() -> void:
	var coins = SaveManager.runtime_data.get("coins", 0)
	coins += 1
	SaveManager.runtime_data["coins"] = coins
	SaveManager.set_temp("coins", coins)

	if SaveManager.hud:
		SaveManager.hud.update_labels()
