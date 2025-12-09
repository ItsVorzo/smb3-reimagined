extends Area2D

var plr: Player

func _ready() -> void:
	add_to_group("Tail")
	plr = get_parent()
	body_entered.connect(tail_attack)

func tail_attack(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.die_from_obj(-sign(plr.global_position.x - body.global_position.x), 60.0)
	elif body.is_in_group("Shell"):
		SoundManager.play_sfx("Kick", global_position)
		body.die(-sign(plr.global_position.x - body.global_position.x), 60.0)
	elif body.is_in_group("Blocks"):
		body.activate(self)
