extends Node2D

@onready var transition: Node2D = $Transition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_menu_pressed() -> void:
	transition.call_deferred("play_anim", "Fade_Out")
	transition.call_deferred("cambio_escena", "res://Escenas/Menus/Menu.tscn")
