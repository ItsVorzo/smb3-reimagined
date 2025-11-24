extends StaticBody2D

@export var switch_duration := 10.0

func _ready():
	$Timer.wait_time = switch_duration

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_parent().activate_switch()

func activate_switch():
	GameManager.p_switch_activated.emit()
	$Timer.start()

func _on_Timer_timeout():
	GameManager.p_switch_expired.emit()
