extends Node2D
const ob = preload("uid://duelamvjwic0t")
var r
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	r = randf_range(750,1200)
	var obstaculo = ob.instantiate()
	obstaculo.global_position.x = r
	add_child(obstaculo)
