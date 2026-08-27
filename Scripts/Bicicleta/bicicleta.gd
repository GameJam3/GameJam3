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
@onready var fuego: TextureRect = $fuego
@onready var o_timer: Timer = $obstacle_timer
const rainbow_z = preload("uid://dkbg8gg3r3jxq")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	player.close_call.connect(_on_player_close_call)
	player.player_death.connect(_on_player_death)
	player.sweet_spot.connect(_on_sweet_spot)
	player.sour_spot.connect(_on_sour_spot)
	player.normal_spot.connect(_on_normal_spot)
	fuego.material.set_shader_parameter("fire_aperture", 3.0)
	fuego.hide()
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
		add_child(obstaculo)
		var t = randf_range(0.3,0.7)
		o_timer.start(t)

func _on_player_close_call () -> void:
	p += 100
	color_anim(points_l,Color.GREEN,Color.WHITE)
	var t : Label = Label.new()
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.pivot_offset = t.size / 2.0
	add_child(t)
	t.set_position(player.global_position)
	t.set_text("Close call!")
	var tween: Tween = create_tween()
	tween.tween_property(t, "scale", Vector2(1.5, 1.5), 0.3).from(Vector2.ZERO)
	tween.tween_property(t, "modulate:a", 0.0, 0.4)
	tween.tween_callback(t.queue_free)

func _on_player_death() -> void:
	rank_calc()

func _on_sweet_spot() -> void:
	extra = 50
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fuego.show()
	fade_tween = create_tween()
	fade_tween.tween_property(fuego.material, "shader_parameter/fire_alpha", 1.0, 0)
	fade_tween.tween_property(fuego.material, "shader_parameter/fire_aperture", 0.22, 1)
	
	
func _on_sour_spot() -> void:
	extra = -10
	
func _on_normal_spot() -> void:
	extra = 0 
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(fuego.material, "shader_parameter/fire_aperture", 3.0, 1)
	fade_tween.tween_property(fuego.material, "shader_parameter/fire_alpha", 0, 2)


func color_anim(l: Label, c1: Color, c2: Color) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(l, "label_settings:font_color", c1,0.0)
	tween.tween_property(l, "label_settings:font_color", c2,0.35)

func _on_tiempo_general_timeout() -> void:
	player.stop = true
	rank_calc()



func _on_survive_timer_timeout() -> void:
	p += 25 + extra

func rank_calc() -> void:
	var r_color: Color
	rank_t.label_settings.outline_size = 15
	rank_t.label_settings.outline_color = Color.WHITE
	match p:
		_ when p < 2000:
			rank = "C"
			r_color = Color.PURPLE
		_ when p < 3000:
			rank = "B"
			r_color = Color.BLUE
		_ when p < 4000:
			rank = "A"
			r_color = Color.GREEN
		_ when p >= 4000 and p < 8000:
			rank = "S"
			r_color = Color.GOLD
		_ when p >= 8000:
			rank = "Z"
			r_color = Color.RED
			rank_t.label_settings.outline_size = 30
			rank_t.label_settings.outline_color = Color.BLACK
			rank_t.material = rainbow_z
	rank_t.set_text(rank)
	rank_t.label_settings.font_color = r_color
