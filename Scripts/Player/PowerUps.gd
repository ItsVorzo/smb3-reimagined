class_name PowerUps
extends Node

@export var tier := 0
@export var animation_type := 1
enum power_ups {Small, Big, Fire, Raccoon, Frog, Tanooki, Hammer, Star, PWing}

var player: Player = owner

func enter() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
