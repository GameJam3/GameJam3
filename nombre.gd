extends Control

@onready var line_edit: LineEdit = $LineEdit
@onready var play: Button = $Play
@onready var transition: Node2D = $Transition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	Global.p_name = line_edit.text
	Global.save_game()
	transition.call_deferred("play_anim", "Fade_Out")
	transition.call_deferred("cambio_escena","res://Escenas/tabla_clasificacion.tscn")
