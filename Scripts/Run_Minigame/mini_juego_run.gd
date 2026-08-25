extends Node2D

@onready var detector: Area2D = $Detector
const TILE = preload("uid://coebnaadnhd85")
var tiles

var area_colliding: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(tiles):
		tiles.global_position.x -= 2

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE) and is_instance_valid(tiles):
		var distancia = detector.global_position.distance_to(tiles.global_position)
		if area_colliding and distancia <= 10.0:
			print("so crack")
			tiles.queue_free()
		elif area_colliding and distancia <= 50.0:
			print("meh")
			tiles.queue_free()
		elif distancia <= 100.0 or distancia >= 50.0:
			print("burro xd")
			tiles.queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	area_colliding = true

func _on_detector_area_exited(area: Area2D) -> void:
	tiles.queue_free()

func _on_timer_timeout() -> void:
	tiles = TILE.instantiate()
	tiles.global_position = $Spawn.global_position
	add_child(tiles)
