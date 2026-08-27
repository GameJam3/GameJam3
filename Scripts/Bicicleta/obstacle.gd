extends Node2D
@onready var rojo: Sprite2D = $auto_rojo
@onready var amarillo: Sprite2D = $auto_amarillo
@onready var blanco: Sprite2D = $auto_blanco
@onready var azul: Sprite2D = $auto_azul
@onready var rojo_2: Sprite2D = $auto_rojo2
@onready var naranja: Sprite2D = $auto_naranja


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var i = randi_range(1,6)
	match i:
		1: 
			amarillo.visible = !amarillo.visible
		2:
			blanco.visible = !blanco.visible
		3:
			azul.visible = !azul.visible
		4:
			rojo_2.visible = !rojo_2.visible
		5:
			naranja.visible = !naranja.visible
		6:
			rojo.visible = !rojo.visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.y += 9



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
