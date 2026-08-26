extends Node2D

@onready var detector: Area2D = $Detector
const TILE: PackedScene = preload("uid://coebnaadnhd85")

var active_tiles: Array[Node2D] = []
var puntaje: int = 0

func _ready() -> void:
	$Timer.start()

func _process(_delta: float) -> void:
	$Puntaje.text = str(puntaje)
	
	for tile in active_tiles:
		if is_instance_valid(tile):
			tile.global_position.x -= 7

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if active_tiles.is_empty():
			return

		var current_tile = active_tiles[0]
		if not is_instance_valid(current_tile):
			active_tiles.pop_front()
			return

		var target_keycode = OS.find_keycode_from_string(current_tile.letra_mostrada)
		
		if event.keycode == target_keycode:
			var distancia = detector.global_position.distance_to(current_tile.global_position)
			
			if distancia <= 10.0:
				puntaje += 150
			elif distancia <= 50.0:
				puntaje += 75
			
			puntaje -= 50
			eliminar_tile(current_tile)
		else:
			puntaje -= 50
			eliminar_tile(current_tile)

func _on_timer_timeout() -> void:
	$Timer.wait_time = snappedf(randf_range(0.5, 2.0), 0.1)
	var new_tile = TILE.instantiate()
	new_tile.global_position = $Spawn.global_position
	add_child(new_tile)
	active_tiles.append(new_tile)

func _on_detector_area_exited(area: Area2D) -> void:
	var tile_exited:Node2D
	
	if area.get_parent() != self:
		tile_exited = area.get_parent()
	else:
		tile_exited = area
		
	eliminar_tile(tile_exited)

func eliminar_tile(tile: Node2D) -> void:
	if tile in active_tiles:
		active_tiles.erase(tile)
	if is_instance_valid(tile):
		tile.queue_free()
