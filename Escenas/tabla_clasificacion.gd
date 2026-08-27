extends Control
@onready var listabici: Label = $listabici
@onready var listarun: Label = $listarun
@onready var listatotal: Label = $listatotal
@onready var listanado: Label = $listanado
@onready var transition: Node2D = $Transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_text_file("res://Assets/bicirank.txt", listabici)
	load_text_file("res://Assets/runrank.txt", listarun)
	load_text_file("res://Assets/nadorank.txt", listanado)
	load_text_file("res://Assets/totalrank.txt", listatotal)
	transition.call_deferred("play_anim", "Fade_In")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func load_text_file(s: String, l: Label) -> void:
	if not FileAccess.file_exists(s):
		print("File does not exist: ", s)
		return
		
	var file = FileAccess.open(s, FileAccess.READ)
	if not file:
		print("Failed to open file. Error code: ", FileAccess.get_open_error())
		return

	var registros: Array[Dictionary] = []
	
	# 1. Leer el archivo y extraer Nombre + Puntaje
	while not file.eof_reached():
		var linea = file.get_line().strip_edges()
		if linea.is_empty():
			continue
			
		var nombre: String = "Jugador"
		var puntaje: int = 0
		var partes: Array = []
		
		# Separa si la línea usa '-' o ',' (soporta .txt y .csv)
		if "-" in linea:
			partes = linea.split("-")
		elif "," in linea:
			partes = linea.split(",")
			
		if partes.size() >= 2:
			nombre = partes[0].strip_edges()
			if partes[1].strip_edges().is_valid_int():
				puntaje = int(partes[1].strip_edges())
		elif linea.is_valid_int(): # Si en el archivo viejo solo había números
			puntaje = int(linea)
			
		registros.append({"nombre": nombre, "puntaje": puntaje})
			
	file.close()

	# 2. Ordenar de mayor a menor según el puntaje
	registros.sort_custom(func(a, b): return a["puntaje"] > b["puntaje"])

	# 3. Guardar SOLO los 10 mejores valores
	var max_registros: int = 7
	if registros.size() > max_registros:
		registros = registros.slice(0, max_registros)

	# 4. Formatear para la pantalla: "1 - Nombre - Puntaje"
	var texto_final: String = ""
	for i in range(registros.size()):
		var reg = registros[i]
		texto_final += "%d. %s - %d\n" % [i + 1, reg["nombre"], reg["puntaje"]]
		
	l.text = texto_final.strip_edges()
	
	# 5. Reescribir el archivo guardando únicamente el Top 10
	_guardar_txt_ordenado(s, registros)


func _guardar_txt_ordenado(s: String, registros: Array[Dictionary]) -> void:
	var file = FileAccess.open(s, FileAccess.WRITE)
	if file:
		for reg in registros:
			# Se guarda con formato "Nombre - Puntaje"
			file.store_line("%s - %d" % [reg["nombre"], reg["puntaje"]])
		file.close()


func _on_menu_pressed() -> void:
	transition.call_deferred("play_anim", "Fade_Out")
	transition.call_deferred("cambio_escena", "res://Escenas/Menus/Menu.tscn")
