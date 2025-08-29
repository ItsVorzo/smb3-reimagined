extends CharacterBody2D

@onready var grab = $Grabbable
var gravity = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not grab.is_grabbed:
		velocity.y += gravity * delta
	else: velocity.y = 0

	move_and_slide()
