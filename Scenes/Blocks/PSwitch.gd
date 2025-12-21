extends CharacterBody2D

@export var p_switch_duration := 600.0
@onready var hitbox: Area2D = $HitBox
var from_block := false
var default_z_index := 0
var is_used := false

func _ready() -> void:
	if from_block:
		global_position.y -= 8
	hitbox.area_entered.connect(pressed)

func object_above(obj: CharacterBody2D) -> bool:
	return obj.global_position.y + 4 < global_position.y

func pressed(area: Area2D) -> void:
	if area.owner.is_in_group("Player") or area.owner.is_in_group("Shell") and not area.owner.grab.is_grabbed:
		if object_above(area.owner):
			GameManager.p_switch_timer = p_switch_duration
			GameManager.p_switch_activated.emit()
			$AnimatedSprite2D.play("pressed")
			$CollisionShape2D.set_deferred("disabled", true)
			hitbox.set_deferred("monitoring", false)
