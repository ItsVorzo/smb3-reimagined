extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func approach(val, target, steps):
	if val < target:
		return min(val + steps, target)
	else:
		return max(val - steps, target)
