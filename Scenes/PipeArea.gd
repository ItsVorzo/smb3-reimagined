class_name PipeArea
extends Node2D

@export_enum("left", "up", "down", "right") var entrance_direction := 0
@export var pipe_id := 0
@export var exit_only := false
@export_file("*.tscn") var level_scene := ""

static var exiting_pipe_id := -1
var can_enter := true

var entered_players := []
var timer := 240

# AHEM. AHEM. most of the pipe system is took from smb1r to get
# an idea of how pipes work, in the future i will rewrite
# a lot of shit because pipes work different in smb3
# (for example, the ready function will be useless in the future)

# Checks if you're exiting a pipe
func _ready() -> void:
	if exiting_pipe_id == pipe_id:
		exit_pipe()

# Check for the players
func _physics_process(_delta: float) -> void:
	for p in $Area2D.get_overlapping_areas():
		if p.owner is Player and not exit_only and can_enter:
			enter_pipe(p.owner)
	if not entered_players.is_empty():
		if timer > 0 and entered_players != GameManager.get_players():
			timer -= 1
			if timer <= 0:
				TransitionManager.fade_to_scene(5.0, 0, 0, 0, level_scene, 30)

# Gets the Vector2 directions
func get_vector(dir := 0) -> Vector2:
	match dir:
		0:
			return Vector2.LEFT
		1:
			return Vector2.UP
		2:
			return Vector2.DOWN
		3:
			return Vector2.RIGHT
		_:
			return Vector2.ZERO

# Matches the pipe direction to the input direction name
func get_input_dir(dir := 0) -> String:
	match dir:
		0:
			return "left"
		1:
			return "up"
		2:
			return "down"
		3:
			return "right"
		_:
			return ""

# Enter
func enter_pipe(plr: Player) -> void:
	if not plr.can_enter_pipe:
		return
	if plr.input.is_action_pressed(get_input_dir(entrance_direction)) and plr.current_grabbed_obj == null and (plr.is_on_floor() or entrance_direction == 1):
		entered_players.append(plr)
		plr.can_enter_pipe = false
		SoundManager.play_sfx("Pipe", global_position)
		if entered_players == GameManager.get_players():
			TransitionManager.fade_to_scene(5.0, 0, 0, 0, level_scene, 30)
		plr.enter_pipe(self)

# Exit
func exit_pipe() -> void:
	can_enter = false
	for p in GameManager.get_players():
		if p.is_node_ready() == false:
			await p.ready
		p.go_to_exit_pipe(self)
	for p in GameManager.get_players():
		if p == null:
			continue
		await get_tree().create_timer(0.3, false).timeout
		await p.exit_pipe(self)
	exiting_pipe_id = -1
	can_enter = true
