extends Node
var p_bici
var p_run
var p_nado
var ranktotal 
var rank_bici: String
var rank_run: String
var rank_nado: String
var p_name: String
func puntajetotal() -> float:
	return (((p_bici / 2) + (p_run) + (p_nado)) / 3)

func save_game() -> void:
	save_score(p_name,p_bici,"res://Assets/bicirank.txt")
	save_score(p_name,p_nado,"res://Assets/nadorank.txt")
	save_score(p_name,p_run,"res://Assets/runrank.txt")
	save_score(p_name,puntajetotal(),"res://Assets/totalrank.txt")

func save_score(player_name: String, score: int, file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end() # Va al final del archivo para no sobreescribir nada
		var line = "%s - %d" % [player_name, score]
		file.store_line(line)
		file.close()
	else:
		# Si el archivo aún no existe, READ_WRITE falla, por lo que se crea con WRITE
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			var line = "%s - %d" % [player_name, score]
			file.store_line(line)
			file.close()
		else:
			push_error("No se pudo abrir ni crear el archivo en: %s" % file_path)
