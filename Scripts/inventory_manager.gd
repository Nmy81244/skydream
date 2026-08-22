extends Node

# Item type ids, as passed to get_item()/remove_item().
enum Type { CONSUMABLE, SOUL, DAGGER, TOME, CHARM }

var inventory = []
var souls = []
var daggers = []
var tomes = []
var charms = []

func _bag(type: int) -> Array:
	match type:
		Type.CONSUMABLE: return inventory
		Type.SOUL: return souls
		Type.DAGGER: return daggers
		Type.TOME: return tomes
		Type.CHARM: return charms
	push_error("InventoryManager: unknown item type %d" % type)
	return []

func _lookup(id: String, type: int) -> Dictionary:
	match type:
		Type.CONSUMABLE: return GlobalDB.consumables(id)
		Type.SOUL: return GlobalDB.souls(id)
		Type.DAGGER: return GlobalDB.daggers(id)
		Type.TOME: return GlobalDB.tomes(id)
		Type.CHARM: return GlobalDB.charms(id)
	return {}

func get_item(id: String, type: int) -> void:
	var data = _lookup(id, type)
	if data.is_empty():
		push_error("InventoryManager: no item '%s' of type %d" % [id, type])
		return
	# Duplicate so each carried item is independent of the shared database entry,
	# and tag it with its id so remove_item() can find it again.
	var item = data.duplicate(true)
	item["id"] = id
	_bag(type).append(item)

func remove_item(id: String, type: int) -> bool:
	var bag = _bag(type)
	for i in range(bag.size()):
		if bag[i].get("id", "") == id:
			bag.remove_at(i)
			return true
	return false
