extends Node2D

@onready var transition: Node2D = $Transition

func _ready() -> void:
	$AnimationPlayer.play("Intro")

func _on_play_pressed() -> void:
	transition.call_deferred("play_anim", "Fade_Out")
	$Timer.start()
	



func _on_timer_timeout() -> void:
	transition.call_deferred("_on_animation_player_animation_finished", "Fade_Out")
