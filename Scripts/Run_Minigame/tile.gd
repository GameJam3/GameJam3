extends Area2D

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Circle 

var pool: Array = ["r", "u", "n", "c", "a"]
var valor: int
var letra_mostrada: String 
var color_tile: Color 

const COLORES: Dictionary = {
	"r": Color.INDIAN_RED,
	"u": Color.CADET_BLUE,
	"n": Color.LAWN_GREEN,
	"c": Color.YELLOW,
	"a": Color.REBECCA_PURPLE
}

func _ready() -> void:
	valor = randi_range(0, pool.size() - 1)
	letra_mostrada = pool[valor]
	label.text = letra_mostrada.capitalize()
	
	color_tile = COLORES.get(letra_mostrada, Color.WHITE)
	sprite.modulate = color_tile
