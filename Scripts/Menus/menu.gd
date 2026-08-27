extends Node2D

@onready var transition: Node2D = $Transition

func _ready() -> void:
	$AnimationPlayer.play("Intro")

func _on_play_pressed() -> void:
	transition.call_deferred("play_anim", "Fade_Out")
	transition.call_deferred("cambio_escena", "res://Escenas/Run_Minijuego/MiniJuegoRun.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	transition.call_deferred("play_anim", "Fade_Out")
	$Timer.start()


func _on_puntajes_pressed() -> void:
	pass # Replace with function body.
