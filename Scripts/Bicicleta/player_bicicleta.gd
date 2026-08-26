extends Node2D
var speed: Vector2
var accel: Vector2
var stop: bool
signal close_call
signal player_death
signal sweet_spot
signal sour_spot
signal normal_spot
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
	if(!stop):
		if(area.is_in_group("closecall")):
			close_call.emit()
		elif (area.is_in_group("sweet_spot")):
			sweet_spot.emit()
		elif (area.is_in_group("sour_spot")):
			sour_spot.emit()
		else:
			accel = Vector2(0,0)
			speed = Vector2(0,0)
			stop = true
			player_death.emit()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if(area.is_in_group("sweet_spot") or area.is_in_group("sour_spot")):
		normal_spot.emit()
