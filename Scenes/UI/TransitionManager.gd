extends Node

@onready var t = $CanvasLayer/ColorRect

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func fade_to_scene(fade_speed := 1.0, r := 0, g := 0, b := 0, scene_path := ""):
	fade_in(fade_speed, r, g, b)
	t.fading_to_scene = true
	t.scene_path = scene_path

func fade_in(fade_speed := 1.0, r := 0, g := 0, b := 0, delay: int = 0):
	t.fade_type = 1
	t.fade_timer = 0.0
	t.fade_speed = fade_speed
	t.r = r
	t.g = g
	t.b = b
	t.is_fading = true
	t.fade_delay = delay

func fade_out(fade_speed := 1.0, r := 0, g := 0, b := 0, delay: int = 0):
	t.fade_type = -1
	t.fade_timer = 255.0
	t.fade_speed = fade_speed
	t.r = r
	t.g = g
	t.b = b
	t.is_fading = true
	t.fade_delay = delay
