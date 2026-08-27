extends Area2D

@export var speed: float = 700.0

func _physics_process(delta: float) -> void:
	var target_y: float = get_global_mouse_position().y
	global_position.y = move_toward(global_position.y, target_y, speed * delta)
