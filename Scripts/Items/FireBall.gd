extends CharacterBody2D

var xspd := 180.0
var bounce := 176.0
var direction := 1.0
@onready var area2d = $Area2D

func _ready() -> void:
	area2d.area_entered.connect(kill)

func _physics_process(delta: float) -> void:

	velocity.x = xspd * direction
	if is_on_floor():
		velocity.y = -bounce
	else:
		velocity.y += 1000.0 * delta

	if is_on_wall() or not GameManager.is_on_screen(global_position):
		if is_on_wall():
			smoke_effect(global_position)
			SoundManager.play_sfx("Hit", global_position)
		queue_free()

	move_and_slide()

func kill(area: Area2D):
	smoke_effect(area.owner.global_position)
	if area.owner.is_in_group("Enemies") and area.owner.can_die_from_fire and not area.owner.dead_from_obj:
		area.owner.die_from_obj(direction, 60)
	elif area.owner.is_in_group("Shell") and not area.owner.is_dead:
		SoundManager.play_sfx("Kick", global_position)
		area.owner.die(direction)
	else:
		SoundManager.play_sfx("Hit", global_position)

	queue_free()

func smoke_effect(pos) -> void:
	var smoke_effect_scene = preload("res://Scenes/Effects/SmokeEffect.tscn")
	var smoke_fx = smoke_effect_scene.instantiate()
	smoke_fx.global_position = pos
	get_parent().add_child(smoke_fx)
