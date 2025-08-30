extends EnemyClass

@onready var sprite := $AnimatedSprite2D
@onready var cstompbox := $CustomStompBox # Stomping works differently here
var direction := 1
var xspd := 30
var gravity = 1000.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_signals()
	cstompbox.body_entered.connect(_on_stomped)
	sprite.play("WalkGreen")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite.scale.x = -direction
	velocity.x = xspd * direction
	if not is_on_floor(): 
		velocity.y += gravity * delta

	move_and_slide()

	if is_on_wall():
		direction *= -1

func _on_stomped(body: Node):
	if body.is_in_group("Player"):
		if body.velocity.y > 0:
			body.bounce_on_enemy()
			SoundManager.play_sfx("Stomp", global_position)
			var shell = load("res://Scenes/Enemies/KoopaShell.tscn").instantiate()
			shell.global_position = global_position
			get_parent().add_child(shell)
			queue_free()
