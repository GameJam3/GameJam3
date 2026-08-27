extends Node2D
const ob = preload("uid://duelamvjwic0t")
var r
var p = 0
var extra = 0
var rank: String
var fade_tween: Tween
@onready var points_l : Label = $points
@onready var player: Node2D = $player
@onready var closecall_text: Label = $closecall_text
@onready var tiempo_l: Label = $tiempo
@onready var tiempo_general: Timer = $tiempo_general
@onready var survive_timer: Timer = $survive_timer
@onready var rank_t: Label = $rank
@onready var o_timer: Timer = $obstacle_timer
const rainbow_z = preload("uid://dkbg8gg3r3jxq")
const anak_font = preload("uid://bcbpgqxrs45xl")
@onready var rainbow_border: ColorRect = $rainbow_border
@onready var transition: Node2D = $Transition
@onready var player_anim: AnimationPlayer = $player_anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	player.close_call.connect(_on_player_close_call)
	player.player_death.connect(_on_player_death)
	player.sweet_spot.connect(_on_sweet_spot)
	player.sour_spot.connect(_on_sour_spot)
	player.normal_spot.connect(_on_normal_spot)
	o_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_P):
		p = 8000
	points_l.set_text("PUNTOS: " + str(p))
	tiempo_l.set_text("TIEMPO: " + str(int(tiempo_general.time_left)))
	if (player.stop):
		survive_timer.stop()
		tiempo_general.stop()

func _on_timer_timeout() -> void:
	if (!player.stop):
		r = randf_range(726,1200)
		var obstaculo = ob.instantiate()
		obstaculo.global_position.x = r
		obstaculo.z_index = -1
		add_child(obstaculo)
		var t = randf_range(0.3,0.7)
		o_timer.start(t)

func _on_player_close_call () -> void:
	p += 100
	color_anim(points_l,Color.GREEN,Color.WHITE)
	var t : Label = Label.new()
	var s := LabelSettings.new()
	s.outline_size = 5
	s.outline_color = Color.GREEN
	t.label_settings = s
	t.add_theme_font_override("font", anak_font)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.pivot_offset = t.size / 2.0
	add_child(t)
	t.set_text("Close call! +100")
	t.reset_size()
	t.pivot_offset = Vector2(t.size.x / 2.0, t.size.y)
	t.set_position(player.global_position - t.pivot_offset) 
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(t, "label_settings:font_size", 28, 0.3).from(Vector2.ZERO)
	tween.tween_property(t, "modulate:a", 0.0, 0.4)
	tween.tween_property(t, "position:y", t.position.y - 100, 0.4)
	tween.chain().tween_callback(t.queue_free)

func _on_player_death() -> void:
	player.dead = true
	var anim: Animation = player_anim.get_animation("player_death")
	var track_idx = anim.find_track("player:position", Animation.TYPE_VALUE)
	var r1 = randi_range(-150,150)
	var r2 = randi_range(-150,150)
	if track_idx != -1:
		anim.track_set_key_value(track_idx,0,player.position)
		anim.track_set_key_value(track_idx,1,player.position - Vector2(r1,r2))
	player_anim.play("player_death")
	await get_tree().create_timer(0.5).timeout
	end_match()

func _on_sweet_spot() -> void:
	extra = 50
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(rainbow_border.material, "shader_parameter/opacity", 1.0, 1)
	
	
func _on_sour_spot() -> void:
	extra = -10
	
func _on_normal_spot() -> void:
	extra = 0 
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(rainbow_border.material, "shader_parameter/opacity", 0, 1)


func color_anim(l: Label, c1: Color, c2: Color) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(l, "label_settings:font_color", c1,0.0)
	tween.tween_property(l, "label_settings:font_color", c2,0.35)

func _on_tiempo_general_timeout() -> void:
	player.stop = true
	if (!player.dead):
		var anim: Animation = player_anim.get_animation("player_win")
		var track_idx = anim.find_track("player:position", Animation.TYPE_VALUE)
		if track_idx != -1:
			anim.track_set_key_value(track_idx,0,player.position)
			anim.track_set_key_value(track_idx,1,player.position + Vector2(0,50))
			anim.track_set_key_value(track_idx,2,player.position + Vector2(0,50))
			anim.track_set_key_value(track_idx,3,player.position + Vector2(0,-2000))
		player_anim.play("player_win")
	await get_tree().create_timer(2).timeout
	end_match()



func _on_survive_timer_timeout() -> void:
	p += 25 + extra

func end_match() -> void:
	var rankquote: String
	Global.p_bici = p
	transition.call_deferred("play_anim", "Fade_Out_Puntaje")
	await get_tree().create_timer(1.5).timeout
	var t1 : Label = Label.new()
	var s1 := LabelSettings.new()

	# 1. Configura el texto y tamaño de fuente PRIMERO
	s1.outline_size = 5
	s1.outline_color = Color.DIM_GRAY
	s1.font_size = 51
	t1.label_settings = s1

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
	rank_t.label_settings.outline_size = 15
	rank_t.label_settings.outline_color = Color.WHITE
	match p:
		_ when p < 4000:
			rank = "C"
			r_color = Color.PURPLE
			rankquote = "Falta sopa"
		_ when p < 6000:
			rank = "B"
			r_color = Color.BLUE
			rankquote = "Podia ser mejor..."
		_ when p < 8000:
			rank = "A"
			r_color = Color.GREEN
			rankquote = "Muy bueno! Podria ser aun mejor..."
		_ when p >= 8000 and p < 16000:
			rank = "S"
			r_color = Color.GOLD
			rankquote = "Excelente!"
		_ when p >= 16000:
			rank = "Z"
			r_color = Color.RED
			rank_t.label_settings.outline_size = 0
			rank_t.label_settings.outline_color = Color.BLACK
			rank_t.material = rainbow_z
			rankquote = "...Como?"
	Global.rank_bici = rank
	rank_t.label_settings.font_color = r_color
	await get_tree().create_timer(3).timeout
	rank_t.set_text(rank)
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
