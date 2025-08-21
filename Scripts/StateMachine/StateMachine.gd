class_name StateMachine
extends Node

@export var initial_state: State = null

@onready var state: State = initial_state


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	state.enter()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state.process_update(delta)

func _physics_process(delta: float) -> void:
	state.physics_process_update(delta)

# Enter a new state
func change_state(target_state_path: String) -> void:
	if not has_node(target_state_path):
		printerr("Trying to access non-existent state! " + target_state_path)
		return

	state.exit()
	state = get_node(target_state_path)
	state.enter()
