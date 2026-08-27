extends Node2D

var puntaje:int = 0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$Monedas.position.x += -10
	$Puntaje.text = str(puntaje)

func _on_personaje_area_entered(area: Area2D) -> void:
	puntaje += 10
