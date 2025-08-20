extends Node
class_name PhysicsVal

# === Flat ground ===
const acc_speed = [3.28125, 3.28125, 3.28125, 3.28125]
const frc_speed = [3.28125, 3.28125, 3.28125, 3.28125]
const ice_frc_speed = [0.703125, 0.703125, 0.703125, 0.703125]
const skid_speed = [7.5, 7.5, 7.5, 7.5]
const ice_skid_speed = [2.8125, 2.8125, 2.8125, 2.8125]
const walk_speed = [90.0, 90.0, 90.0, 90.0]
const run_speed = [150.0, 150.0, 150.0, 150.0]
const p_speed = [210.0, 210.0, 210.0, 210.0]
const end_level_walk = 75.0
const airship_cutscene_walk = 120.0

# === Slopes ===
const uphill_max_walk = [48.75, 48.75, 48.75, 48.75]
const uphill_max_run = [82.5, 82.5, 82.5, 82.5]
const sliding_max_speed = 236.25

# === Mid-air ===
const jump_speeds = [-217.5, -225.0, -240, -258.75,
					-217.5, -225.0, -240, -258.75,
					-217.5, -225.0, -240, -258.75,
					-217.5, -225.0, -240, -258.75
					]

const low_gravity = [256.0, 256.0, 256.0, 256.0]
const high_gravity = [1280.0, 1280.0, 1280.0, 1280.0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
