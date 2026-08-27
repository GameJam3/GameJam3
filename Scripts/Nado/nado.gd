extends Node2D

var puntaje:int = 0
@onready var puntaje_l: Label = $Puntaje
@onready var rank_l: Label = $Rank
@onready var drumroll: AudioStreamPlayer = $drumroll
@onready var ranksfx: AudioStreamPlayer = $ranksfx
@onready var transition: Node2D = $Transition
const rainbow_z = preload("uid://dkbg8gg3r3jxq")
const anak_font = preload("uid://bcbpgqxrs45xl")

var jugando:bool = true
var rank:String

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if jugando:
		$Monedas.position.x += -10
		$Puntaje.text = str(puntaje)

func _on_personaje_area_entered(area: Area2D) -> void:
	puntaje += 100

func end_match() -> void:
	var rankquote: String
	Global.p_nado = puntaje
	transition.call_deferred("play_anim", "Fade_Out_Puntaje")
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
		_ when puntaje < 4000:
			rank = "C"
			r_color = Color.PURPLE
			rankquote = "Falta sopa"
			ranksfx.stream = load("res://Assets/Run/bad.ogg")
		_ when puntaje < 6000:
			rank = "B"
			r_color = Color.BLUE
			rankquote = "Podia ser mejor..."
			ranksfx.stream = load("res://Assets/Run/meh.ogg")
		_ when puntaje < 8000:
			rank = "A"
			r_color = Color.GREEN
			rankquote = "Muy bueno! Podria ser aun mejor..."
			ranksfx.stream = load("res://Assets/Run/good.ogg")
		_ when puntaje >= 8000 and puntaje < 16000:
			rank = "S"
			r_color = Color.GOLD
			rankquote = "Excelente!"
			ranksfx.stream = load("res://Assets/Run/good.ogg")
		_ when puntaje >= 16000:
			rank = "Z"
			r_color = Color.RED
			rank_l.label_settings.outline_size = 0
			rank_l.label_settings.outline_color = Color.BLACK
			rank_l.material = rainbow_z
			rankquote = "...Como?"
			ranksfx.stream = load("res://Assets/angel.mp3")
			ranksfx.volume_db = -10
	Global.rank_nado = rank
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
	puntaje_l.z_index = 21
	$Button.visible = true
	$AudioStreamPlayer2D.stop()
	$ColorRect.visible = true 
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	add_child(t2)
	
	# 2. Recalcula el tamaño del Label con la nueva fuente/texto
	t2.reset_size()

	# 3. Asigna el pivot exacto
	t2.pivot_offset = Vector2(t2.size.x / 2.0, t2.size.y)

	# 4. Ajusta la posición X restando la mitad del ancho del Label
	var target_center_x1 := 960.0
	var target_y1 := 500.0
	t2.set_position(Vector2(target_center_x1 - (t2.size.x / 2.0), target_y1))


func _on_timer_timeout() -> void:
	end_match()
	jugando=false


func _on_button_pressed() -> void:
	transition.z_index = 25
	transition.call_deferred("play_anim", "Fade_Out")
	transition.call_deferred("cambio_escena", "res://Escenas/Menus/nombre.tscn")
