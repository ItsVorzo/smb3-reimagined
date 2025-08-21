extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player") and body.velocity.y < 0:
		get_parent().hit_from_below(body)
