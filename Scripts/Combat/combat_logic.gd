extends Node

var fight_type = 1 # 1N 2U 3B 4S
var enemy_count = 0
var current_encounter: Array = []

var player_queue = []
var enemy_queue = []
var queue = []
var queue_size = 6

var _last_printed_second := -1

func start_fight(enemies: Array, type: int):
	current_encounter = enemies
	enemy_count = enemies.size()
	fight_type = type
	queue_size = (enemy_count + 1) * (fight_type + 1)
	player_queue.clear()
	enemy_queue.clear()
	queue.clear()
	get_tree().change_scene_to_file("res://Scenes/combat.tscn")

# Returns the queued action, or an empty array if the queue was full.
# Pass the returned value to free_action() to release the slot.
func add_action(author: int, input_id: String, type: int, index: int = 0) -> Array: # 1A 2S 3E 4C 5D
	var duration = 0.0
	if type == 2:
		duration = GlobalDB.spells(input_id).get("duration", 0.0)
	else:
		duration = 0.5
	var ind = queue.size()
	var jnd = player_queue.size() if author else enemy_queue.size()
	var action = [author, ind, jnd, input_id, type, duration, index]

	if queue.size() >= queue_size:
		return []

	var side = player_queue if author else enemy_queue
	if side.size() >= queue_size / 2:
		return []

	side.append(action)
	queue.append(action)
	return action

func free_action(action_or_side, index := null) -> void:
	# Accept either a queued action Array, or (is_player: bool, index: int)
	if index == null:
		var action = action_or_side
		if action.is_empty():
			return
		if action[0]:
			player_queue.erase(action)
		else:
			enemy_queue.erase(action)
		queue.erase(action)
		return
	# Called as free_action(is_player: bool, index: int)
	var is_player: bool = bool(action_or_side)
	var i: int = int(index)
	if is_player:
		if i >= 0 and i < player_queue.size():
			var act = player_queue[i]
			player_queue.remove_at(i)
			queue.erase(act)
	else:
		if i >= 0 and i < enemy_queue.size():
			var act = enemy_queue[i]
			enemy_queue.remove_at(i)
			queue.erase(act)

func print_queue() -> void:
	print("[CombatQueue] Total: %d/%d | Player: %s | Enemy: %s | Player | HP: %d/%d MP: %d/%d" % [queue.size(), queue_size, str(player_queue), str(enemy_queue), PlayerStats.health, PlayerStats.max_health, PlayerStats.mana, PlayerStats.max_mana])

func _process(_delta: float) -> void:
	var seconds_passed := int(floor(GlobalDB.timer))
	if seconds_passed != _last_printed_second:
		_last_printed_second = seconds_passed
		print_queue()
