extends EnemyClass

@export var jump_force := -400.0
@export var gravity := 1000.0
@export var jump_interval := 2.0

var jumping := false
var start_y := 0.0

@onready var jump_timer: Timer = $Timer

func _ready() -> void:
	start_y = global_position.y
	jump_timer.wait_time = jump_interval
	jump_timer.start()
	set_signals()

func _physics_process(delta: float) -> void:
	if stomped:
		return

	if jumping:
		self.velocity.y += gravity * delta  # ✅ use built-in velocity
		if global_position.y >= start_y:
			global_position.y = start_y
			self.velocity.y = 0.0
			jumping = false
			jump_timer.start()
	else:
		self.velocity.y = 0.0

	move_and_slide()
	process()

func _on_timer_timeout() -> void:
	jumping = true
	self.velocity.y = jump_force  # ✅ use built-in velocity
