extends Node2D

@onready var detector: Area2D = $Detector
@onready var test: Area2D = $Test

var area_colliding: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(test):
		test.position.x -= 1
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE) and is_instance_valid(test):
		var distancia = detector.global_position.distance_to(test.global_position)
		if area_colliding and distancia <= 20.0:
			print("so crack")
		elif area_colliding and distancia >= 60.0:
			print("meh")
		elif distancia > 100.0:
			print("burro xd")
			test.queue_free()
			
func _on_area_2d_area_entered(area: Area2D) -> void:
	area_colliding = true
	
