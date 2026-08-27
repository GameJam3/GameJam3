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
	var anim: Animation = player_anim.get_animation("player_death")
	var track_idx = anim.find_track("player:position", Animation.TYPE_VALUE)
	var r1 = randi_range(-150,150)
	var r2 = randi_range(-150,150)
	if track_idx != -1:
		anim.track_set_key_value(track_idx,0,player.position)
		anim.track_set_key_value(track_idx,1,player.position - Vector2(r1,r2))
	player_anim.play("player_death")
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
	end_match()



func _on_survive_timer_timeout() -> void:
	p += 25 + extra

func end_match() -> void:
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
			rank_t.label_settings.outline_size = 0
			rank_t.label_settings.outline_color = Color.BLACK
			rank_t.material = rainbow_z
	rank_t.set_text(rank)
	rank_t.label_settings.font_color = r_color
	transition.call_deferred("play_anim", "Fade_Out_Puntaje")
