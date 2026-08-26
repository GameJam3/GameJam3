extends Node2D
const ob = preload("uid://duelamvjwic0t")
var r
var p = 0
var extra = 0
@onready var points_l: Label = $points
@onready var player: Node2D = $player
@onready var closecall_text: Label = $closecall_text
@onready var tiempo_l: Label = $tiempo
@onready var tiempo_general: Timer = $tiempo_general
@onready var survive_timer: Timer = $survive_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	player.close_call.connect(_on_player_close_call)
	player.player_death.connect(_on_player_death)
	player.sweet_spot.connect(_on_sweet_spot)
	player.sour_spot.connect(_on_sour_spot)
	player.normal_spot.connect(_on_normal_spot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	points_l.set_text("puntos: " + str(p))
	tiempo_l.set_text("tiempo: " + str(int(tiempo_general.time_left)))
	if (player.stop):
		survive_timer.stop()
	print(extra)

func _on_timer_timeout() -> void:
	if (!player.stop):
		r = randf_range(665,1350)
		var obstaculo = ob.instantiate()
		obstaculo.global_position.x = r
		add_child(obstaculo)

func _on_player_close_call () -> void:
	p += 100
	color_anim(points_l,Color.BLUE,Color.WHITE)
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
	pass

func _on_sweet_spot() -> void:
	extra = 15
	
func _on_sour_spot() -> void:
	extra = -10
	
func _on_normal_spot() -> void:
	extra = 0 

func color_anim(l: Label, c1: Color, c2: Color) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(l, "label_settings:font_color", c1,0.0)
	tween.tween_property(l, "label_settings:font_color", c2,0.35)

func _on_tiempo_general_timeout() -> void:
	player.stop = true

func _on_survive_timer_timeout() -> void:
	p += 25 + extra
