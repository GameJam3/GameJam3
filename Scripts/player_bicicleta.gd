extends Node2D
var speed: Vector2
var accel: Vector2
var stop: bool
@onready var obstacle: Area2D = $"../obstacle"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed.x = accel.x * 0.4
	speed.y = accel.y * 0.4
	if (!stop): 
		if Input.is_key_pressed(KEY_A):
			accel.x += 0.4
			position.x -= speed.x
		if Input.is_key_pressed(KEY_D):
			accel.x += 0.4
			position.x += speed.x
		if Input.is_key_pressed(KEY_S):
			accel.y += 0.4
			position.y += speed.y
		if Input.is_key_pressed(KEY_W):
			accel.y += 0.4
			position.y -= speed.y
	accel.x -= 0.3
	accel.y -= 0.3
	if (accel.x < 0):
		accel.x = 0
	if (accel.y < 0):
		accel.y = 0
	if (accel.y > 10):
		accel.y = 10
	if (accel.x > 10):
		accel.x = 10

func _on_area_2d_area_entered(area: Area2D) -> void:
	accel = Vector2(0,0)
	speed = Vector2(0,0)
	stop = true
