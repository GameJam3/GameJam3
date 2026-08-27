extends Area2D

@export var speed: float = 300.0

func _physics_process(delta: float) -> void:
	var direccion: float = 0.0
	
	if Input.is_key_pressed(KEY_W):
		direccion -= 1.0
	if Input.is_key_pressed(KEY_S):
		direccion += 1.0
		
	position.y += direccion * speed * delta
