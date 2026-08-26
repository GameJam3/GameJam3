extends Area2D

@onready var label: Label = $Label

var pool:Array = ["r","u","n","c"]
var valor:int
var letra_mostrada:String 

func _ready() -> void:
	randomize()
	valor = randi_range(0, pool.size() - 1)
	letra_mostrada = pool[valor]
	label.text = letra_mostrada.capitalize()
