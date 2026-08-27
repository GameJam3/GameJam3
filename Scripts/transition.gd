extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("Fade_In")



func play_anim(anim_name: StringName):
	animation_player.play(anim_name)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fade_Out": 
		get_tree().change_scene_to_file("res://Escenas/Run_Minijuego/MiniJuegoRun.tscn")
