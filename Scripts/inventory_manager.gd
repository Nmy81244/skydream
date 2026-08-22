extends Node

var inventory = []
var souls = []
var daggers = []
var tomes = []
var charms = []

func get_item(id: String, type: int):
	match type:
		0: inventory.append(GlobalDB.consumables(id))
		1: souls.append(GlobalDB.souls(id))
		2: daggers.append(GlobalDB.daggers(id))
		3: tomes.append(GlobalDB.tomes(id))
		4: charms.append(GlobalDB.charms(id))
		
func remove_item(id: String, type: int):
	match type:
		0: inventory.remove(GlobalDB.consumables(id))
		1: souls.remove(GlobalDB.souls(id))
		2: daggers.remove(GlobalDB.daggers(id))
		3: tomes.remove(GlobalDB.tomes(id))
		4: charms.remove(GlobalDB.charms(id))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
