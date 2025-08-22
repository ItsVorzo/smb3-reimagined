class_name PowerUps
extends Node

@export var tier: int
enum power_ups {Small, Big, Fire, Raccoon, Frog, Tanooki}

@onready var player: Player = owner

func enter() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
