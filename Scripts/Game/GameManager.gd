extends Node

# will work on this later
var cam: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass #print(PlayerManager.player_data)
