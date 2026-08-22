# item_database.gd (Autoload: GlobalDB)
extends Node

var timer = 0.0

var souls_data: Dictionary = {}
var daggers_data: Dictionary = {}
var tomes_data: Dictionary = {}
var charms_data: Dictionary = {}
var spells_data: Dictionary = {}
var consumables_data: Dictionary = {}
var enemies_data: Dictionary = {}

func _ready():
	souls_data = _load_json("res://Tables/Equip/souls.json")
	daggers_data = _load_json("res://Tables/Equip/daggers.json")
	tomes_data = _load_json("res://Tables/Equip/tomes.json")
	charms_data = _load_json("res://Tables/Equip/charms.json")	
	spells_data = _load_json("res://Tables/Items/spells.json")
	consumables_data = _load_json("res://Tables/Items/consumables.json")
	enemies_data = _load_json("res://Tables/Characters/enemies.json")

func _load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("GlobalDB: could not open %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return {}
	var content = file.get_as_text()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) == TYPE_OBJECT and parsed.has("error"):
		# Godot 4's JSON.parse_string returns a JSONParseResult object
		if parsed.error != OK:
			push_error("GlobalDB: failed to parse %s (error %d)" % [path, parsed.error])
			return {}
		var result = parsed.result
		if typeof(result) != TYPE_DICTIONARY:
			push_error("GlobalDB: %s is not a valid JSON object" % path)
			return {}
		return result
	# Fallback for older Godot versions where parse_string returned the dict directly
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("GlobalDB: %s is not a valid JSON object" % path)
		return {}
	return parsed

func souls(id: String) -> Dictionary:
	return souls_data.get(id, souls_data.get("000", {}))

func daggers(id: String) -> Dictionary:
	return daggers_data.get(id, daggers_data.get("000", {}))

func tomes(id: String) -> Dictionary:
	return tomes_data.get(id, tomes_data.get("000", {}))

func charms(id: String) -> Dictionary:
	return charms_data.get(id, charms_data.get("000", {}))

func spells(id: String) -> Dictionary:
	return spells_data.get(id, spells_data.get("0000001", {}))

func consumables(id: String) -> Dictionary:
	return consumables_data.get(id, consumables_data.get("000000", {}))
	
func enemies(id: String) -> Dictionary:
	return enemies_data.get(id, enemies_data.get("000", {}))

func _process(delta: float) -> void:
	timer += delta
