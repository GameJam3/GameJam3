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
@onready var bad: AudioStreamPlayer2D = $SFX/Bad
@onready var meh: AudioStreamPlayer2D = $SFX/Meh
@onready var rank_l: Label = $Rank
@onready var ranksfx: AudioStreamPlayer2D = $SFX/ranksfx
@onready var drumroll: AudioStreamPlayer = $SFX/drumroll

const rainbow_z = preload("uid://dkbg8gg3r3jxq")
const anak_font = preload("uid://bcbpgqxrs45xl")
const TILE: PackedScene = preload("uid://coebnaadnhd85")

var multiplicador_v: float = 1.0
var active_tiles: Array[Node2D] = []
var puntaje: int = 0
var tween_circulo: Tween 
var tween_puntaje: Tween 
var rank: String

enum State { BOOSTED, NORMAL, BAD, SLOW }
var estado_actual: State = State.NORMAL

var racha_verdes: int = 0
var racha_fallos: int = 0

func _ready() -> void:
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
				muestra_puntaje(150)
			elif distancia <= 125.0:
				puntaje += 75
				meh.play()
				actualizar_color_circulo(Color.YELLOW) 
				actualizar_color_puntaje(Color.GREEN) 
				registrar_fallo()
				eliminar_tile(current_tile)
				muestra_puntaje(75)
			else:
				puntaje -= 50
				bad.play()
				actualizar_color_circulo(Color.RED) 
				actualizar_color_puntaje(Color.RED) 
				registrar_fallo()
				eliminar_tile(current_tile)
				muestra_puntaje(-50)
		else:
			if distancia <= 125.0:
				bad.play()
				puntaje -= 25
				muestra_puntaje(-25)
			else:
				bad.play()
				puntaje -= 50
				muestra_puntaje(-50)
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
		bad.play()
		puntaje -= 25
		actualizar_color_circulo(Color.RED)
		actualizar_color_puntaje(Color.RED) 
		registrar_fallo()
		eliminar_tile(tile_exited)
		muestra_puntaje(-25)

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
	rank_calc()
	
	# Vacía el arreglo primero para evitar penalizaciones en detector_area_exited
	var tiles_a_eliminar = active_tiles.duplicate()
	active_tiles.clear()
	for tile in tiles_a_eliminar:
		if is_instance_valid(tile):
			tile.queue_free()

	var anim: Animation = animation_player.get_animation("Final")
	
	var track_idx = anim.find_track("Player:position", Animation.TYPE_VALUE)
	
	if track_idx != -1:
		anim.track_set_key_value(track_idx, 0, player_sprite.position)
	
	animation_player.play("Final")
	
func muestra_puntaje(puntos_obtenidos: int) -> void:
	var t: Label = Label.new()
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var fuente = load("res://Assets/Fonts/Anak Orang.ttf")
	t.add_theme_font_override("font", fuente)
	t.add_theme_font_size_override("font_size", 70)
	t.add_theme_color_override("font_outline_color", Color.BLACK)
	t.add_theme_constant_override("outline_size", 30) 
	
	if puntos_obtenidos > 0:
		t.set_text("+" + str(puntos_obtenidos))
	else:
		t.set_text(str(puntos_obtenidos))
	
	if puntos_obtenidos >= 150:
		t.modulate = Color.GREEN
	elif puntos_obtenidos > 0:
		t.modulate = Color.YELLOW
	else:
		t.modulate = Color.RED

	add_child(t)
	t.reset_size()
	t.pivot_offset = Vector2(t.size.x / 2.0, t.size.y)
	t.set_position($Circle.global_position - Vector2(t.size.x / 2.0, 100))
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(t, "scale", Vector2(1, 1), 0.3).from(Vector2.ZERO)
	tween.tween_property(t, "position:y", t.position.y - 50, 0.4)
	tween.tween_property(t, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(t.queue_free)

func _on_pitchscale_timeout() -> void:
	multiplicador_v += 0.06
	print(multiplicador_v)

func rank_calc() -> void:
	var rankquote: String
	rank_l.z_index = 21
	$Button.show()
	$Button.z_index = 21
	await get_tree().create_timer(1.5).timeout
	var t1 : Label = Label.new()
	var s1 := LabelSettings.new()

	# 1. Configura el texto y tamaño de fuente PRIMERO
	s1.outline_size = 5
	s1.outline_color = Color.DIM_GRAY
	s1.font_size = 51
	t1.label_settings = s1
	drumroll.play()
	t1.add_theme_font_override("font", anak_font)
	t1.set_text("Tu calificacion es...")
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t1.z_index = 21

	add_child(t1)

	# 2. Recalcula el tamaño del Label con la nueva fuente/texto
	t1.reset_size()

	# 3. Asigna el pivot exacto
	t1.pivot_offset = Vector2(t1.size.x / 2.0, t1.size.y)

	# 4. Ajusta la posición X restando la mitad del ancho del Label
	var target_center_x := 960.0
	var target_y := 165.0
	t1.set_position(Vector2(target_center_x - (t1.size.x / 2.0), target_y))
	var r_color: Color
	rank_l.label_settings.outline_size = 15
	rank_l.label_settings.outline_color = Color.WHITE
	match puntaje:
		_ when puntaje < 2000:
			rank = "C"
			r_color = Color.PURPLE
			rankquote = "Falta sopa"
			ranksfx.stream = load("res://Assets/Run/bad.ogg")
		_ when puntaje < 3000:
			rank = "B"
			r_color = Color.BLUE
			rankquote = "Podia ser mejor..."
			ranksfx.stream = load("res://Assets/Run/meh.ogg")
		_ when puntaje < 4000:
			rank = "A"
			r_color = Color.GREEN
			rankquote = "Muy bueno! Podria ser aun mejor..."
			ranksfx.stream = load("res://Assets/Run/good.ogg")
		_ when puntaje >= 5000 and puntaje < 7500:
			rank = "S"
			r_color = Color.GOLD
			rankquote = "Excelente!"
			ranksfx.stream = load("res://Assets/Run/good.ogg")
		_ when puntaje >= 75000:
			rank = "Z"
			r_color = Color.RED
			rank_l.label_settings.outline_size = 0
			rank_l.label_settings.outline_color = Color.BLACK
			rank_l.material = rainbow_z
			rankquote = "...Como?"
			ranksfx.stream = load("res://Assets/angel.mp3")
			ranksfx.volume_db = -10
	Global.rank_run = rank
	Global.p_run = puntaje
	rank_l.label_settings.font_color = r_color
	await get_tree().create_timer(3).timeout
	rank_l.set_text(rank)
	ranksfx.play()
	await get_tree().create_timer(1).timeout
	var t2 : Label = Label.new()
	var s2 := LabelSettings.new()

	# 1. Configura el texto y tamaño de fuente PRIMERO
	s2.outline_size = 5
	s2.outline_color = Color.DIM_GRAY
	s2.font_size = 51
	t2.label_settings = s2

	t2.add_theme_font_override("font", anak_font)
	t2.set_text(rankquote)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t2.z_index = 21

	add_child(t2)

	# 2. Recalcula el tamaño del Label con la nueva fuente/texto
	t2.reset_size()

	# 3. Asigna el pivot exacto
	t2.pivot_offset = Vector2(t2.size.x / 2.0, t2.size.y)

	# 4. Ajusta la posición X restando la mitad del ancho del Label
	var target_center_x1 := 960.0
	var target_y1 := 500.0
	t2.set_position(Vector2(target_center_x1 - (t2.size.x / 2.0), target_y1))

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/Bicicleta/bicicleta.tscn")
