extends Node2D

@onready var detector: Area2D = $Detector
@onready var particulas: GPUParticles2D = $GPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var transition: Node2D = $Transition
@onready var circle: Sprite2D = $Circle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: AnimatedSprite2D = $Player
@onready var parallax: Parallax2D = $Parallax2D
@onready var good: AudioStreamPlayer2D = $SFX/Good

const TILE: PackedScene = preload("uid://coebnaadnhd85")

var multiplicador_v: float = 1.0
var active_tiles: Array[Node2D] = []
var puntaje: int = 0
var tween_circulo: Tween 
var tween_puntaje: Tween 

enum State { BOOSTED, NORMAL, BAD, SLOW }
var estado_actual: State = State.NORMAL

var racha_verdes: int = 0
var racha_fallos: int = 0

func _ready() -> void:
	audio_stream_player_2d.play()
	$Timer.start()
	
	animation_player.play("Good") 
	cambiar_estado(State.NORMAL)

func _physics_process(delta: float) -> void:
	$Puntaje.text = str(puntaje)
	
	for tile in active_tiles:
		if is_instance_valid(tile):
			tile.global_position.x -= 12 * multiplicador_v

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
			if distancia <= 25.0:
				puntaje += 150
				good.play()
				actualizar_color_circulo(Color.GREEN) 
				actualizar_color_puntaje(Color.GREEN) 
				registrar_acierto_verde() 
				eliminar_tile(current_tile)
			elif distancia <= 125.0:
				puntaje += 75
				good.play()
				actualizar_color_circulo(Color.YELLOW) 
				actualizar_color_puntaje(Color.GREEN) 
				registrar_fallo()
				eliminar_tile(current_tile)
			else:
				puntaje -= 50
				actualizar_color_circulo(Color.RED) 
				actualizar_color_puntaje(Color.RED) 
				registrar_fallo()
				eliminar_tile(current_tile)
		else:
			if distancia <= 125.0:
				puntaje -= 25
			else:
				puntaje -= 50
			actualizar_color_circulo(Color.RED) 
			actualizar_color_puntaje(Color.RED) 
			registrar_fallo()
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
		actualizar_color_circulo(Color.RED)
		actualizar_color_puntaje(Color.RED) 
		registrar_fallo()
		eliminar_tile(tile_exited)

func registrar_acierto_verde() -> void:
	racha_verdes += 1
	racha_fallos = 0
	
	match estado_actual:
		State.SLOW:
			if racha_verdes >= 2:
				cambiar_estado(State.BAD)
		State.BAD:
			if racha_verdes >= 2:
				cambiar_estado(State.NORMAL)
		State.NORMAL:
			if racha_verdes >= 3:
				cambiar_estado(State.BOOSTED)

func registrar_fallo() -> void:
	racha_fallos += 1
	racha_verdes = 0
	
	match estado_actual:
		State.BOOSTED:
			if racha_fallos >= 3:
				cambiar_estado(State.NORMAL)
		State.NORMAL:
			if racha_fallos >= 3:
				cambiar_estado(State.BAD)
		State.BAD:
			if racha_fallos >= 3:
				cambiar_estado(State.SLOW)

func cambiar_estado(nuevo_estado: State) -> void:
	var era_estado_bueno = (estado_actual == State.BOOSTED or estado_actual == State.NORMAL)
	var es_estado_bueno = (nuevo_estado == State.BOOSTED or nuevo_estado == State.NORMAL)
	
	estado_actual = nuevo_estado
	racha_verdes = 0
	racha_fallos = 0
	
	if era_estado_bueno and not es_estado_bueno:
		animation_player.play("Bad")
	elif not era_estado_bueno and es_estado_bueno:
		animation_player.play("Good")
		
	match estado_actual:
		State.BOOSTED:
			player_sprite.speed_scale = 12.0 / 8.0 
			parallax.autoscroll.x = -350
		State.NORMAL:
			player_sprite.speed_scale = 1.0
			parallax.autoscroll.x = -250
		State.BAD:
			player_sprite.speed_scale = 1.0 
			parallax.autoscroll.x = -250
		State.SLOW:
			player_sprite.speed_scale = 5.0 / 8.0 
			parallax.autoscroll.x = -150

func actualizar_color_circulo(nuevo_color: Color) -> void:
	if tween_circulo and tween_circulo.is_valid():
		tween_circulo.kill()
		
	circle.modulate = nuevo_color
	
	tween_circulo = create_tween()
	tween_circulo.tween_interval(0.08) 
	tween_circulo.tween_property(circle, "modulate", Color.WHITE, 0.12) 

# CAMBIO: Función para cambiar el color del Label del puntaje y regresar suavemente a blanco
func actualizar_color_puntaje(nuevo_color: Color) -> void:
	if tween_puntaje and tween_puntaje.is_valid():
		tween_puntaje.kill()
		
	$Puntaje.modulate = nuevo_color
	
	tween_puntaje = create_tween()
	tween_puntaje.tween_interval(0.08) 
	tween_puntaje.tween_property($Puntaje, "modulate", Color.WHITE, 0.12) 

func eliminar_tile(tile: Node2D) -> void:
	if tile in active_tiles:
		active_tiles.erase(tile)
	if is_instance_valid(tile):
		tile.queue_free()

func _on_audio_stream_player_2d_finished() -> void:
	$Timer.stop()
	set_process_unhandled_input(false)
	
	var anim: Animation = animation_player.get_animation("Final")
	
	var track_idx = anim.find_track("Player:position", Animation.TYPE_VALUE)
	
	if track_idx != -1:
		anim.track_set_key_value(track_idx, 0, player_sprite.position)
	
	animation_player.play("Final")

func _on_pitchscale_timeout() -> void:
	multiplicador_v += 0.06
	print(multiplicador_v)
