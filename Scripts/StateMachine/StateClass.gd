class_name State
extends Node

# === You basically get basic state machine functions here ===

@onready var state_machine: StateMachine = get_parent()

# Basically _ready() but for states
func enter() -> void:
	pass

# Basically _process() but for states
func process_update(_delta: float) -> void:
	pass

# Basically _physics_process() but for states
func physics_process_update(_delta: float) -> void:
	pass

# Called by the state machine when you're exiting a state
# you should put stuff like resetting flags or stuff like that
func exit() -> void:
	pass
