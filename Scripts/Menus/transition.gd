extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var transition: Node2D = $Transition
var nombreEscena: String


func _ready() -> void:
	transition.visible = true
	animation_player.play("Fade_In")
	nombreEscena = ""

func play_anim(anim_name: StringName):
	transition.visible = true
	animation_player.play(anim_name)

func cambio_escena(escena: String):
	nombreEscena = escena

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fade_In": 
		transition.visible = false
	elif anim_name == "Fade_Out":
		get_tree().change_scene_to_file(nombreEscena)
