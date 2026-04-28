class_name LevelLoader
extends RefCounted

# Ucitava level iz JSON fajla i vraca Dictionary sa podacima.
# Vraca prazan Dictionary ako fajl ne postoji ili je JSON nevalidan.
static func load_level(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Level fajl ne postoji: " + path)
		return {}
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Ne mogu da otvorim fajl: " + path)
		return {}
	
	var json_text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("JSON parse greska u " + path + ": " + json.get_error_message())
		return {}
	
	var data = json.data
	if not data is Dictionary:
		push_error("Level JSON mora biti objekat (Dictionary)")
		return {}
	
	var required := ["name", "slots", "pool"]
	for key in required:
		if not data.has(key):
			push_error("Level fajl nema polje '" + key + "': " + path)
			return {}
	
	return data
