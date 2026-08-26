extends Node2D

@onready var detector: Area2D = $Detector
@onready var particulas: GPUParticles2D = $GPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

const TILE: PackedScene = preload("uid://coebnaadnhd85")

var multiplicador_v:float
var active_tiles: Array[Node2D] = []
var puntaje: int = 0

func _ready() -> void:
	audio_stream_player_2d.play()
	$Timer.start()

func _physics_process(delta: float) -> void:
	$Puntaje.text = str(puntaje)
	
	for tile in active_tiles:
		if is_instance_valid(tile):
			tile.global_position.x -= 9 * multiplicador_v

func _process(delta: float) -> void:
	multiplicador_v = audio_stream_player_2d.pitch_scale

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if active_tiles.is_empty():
			return

		var current_tile = active_tiles[0]
		if not is_instance_valid(current_tile):
			active_tiles.pop_front()
			return

		var target_keycode = OS.find_keycode_from_string(current_tile.letra_mostrada)
		var distancia = detector.global_position.distance_to(current_tile.global_position)
		
		particulas.global_position = current_tile.global_position
		particulas.modulate = current_tile.color_tile 
		particulas.restart()
	
		if event.keycode == target_keycode:
			print(distancia)
			
			if distancia <= 25.0:
				print("pro")
				puntaje += 150
				eliminar_tile(current_tile)
			elif distancia <= 125.0:
				print("meh")
				puntaje += 75
				eliminar_tile(current_tile)
			else:
				puntaje -= 50
				eliminar_tile(current_tile)
		else:
			if distancia <= 125.0:
				puntaje -= 25
			else:
				puntaje -= 50
			eliminar_tile(current_tile)

func _on_timer_timeout() -> void:
	$Timer.wait_time = randi_range(1, 8) * 0.5 / multiplicador_v
	var new_tile = TILE.instantiate()
	new_tile.global_position = $Spawn.global_position
	add_child(new_tile)
	active_tiles.append(new_tile)

func _on_detector_area_exited(area: Area2D) -> void:
	var tile_exited: Node2D
	
	if area.get_parent() != self:
		tile_exited = area.get_parent()
	else:
		tile_exited = area
		
	if tile_exited in active_tiles:
		puntaje -= 25
		eliminar_tile(tile_exited)

func eliminar_tile(tile: Node2D) -> void:
	if tile in active_tiles:
		active_tiles.erase(tile)
	if is_instance_valid(tile):
		tile.queue_free()


func _on_timer_2_timeout() -> void:
	audio_stream_player_2d.pitch_scale = 1.5
