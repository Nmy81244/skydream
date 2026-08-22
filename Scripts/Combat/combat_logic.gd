extends Node

var fight_type = 1 # 1N 2U 3B 4S
var enemy_count = 0
var current_encounter: Array = []

var player_queue = []
var enemy_queue = []
var queue = []
var queue_size = 6
var battle_start_delay := 3.0
var battle_start_time := 0.0

var _last_printed_second := -1

func action_speed_multiplier() -> float:
	return randf_range(0.925, 1.075)

func accuracy_with_level(acc: float, attacker_level: int, defender_level: int) -> float:
	var diff = int(attacker_level) - int(defender_level)
	var absd = abs(diff)
	var ad = 0.0
	if absd >= 7:
		ad = 0.8
	elif absd >= 5:
		ad = 0.5
	elif absd >= 3:
		ad = 0.25
	else:
		ad = 0.0
	if diff > 0:
		return acc * (1.0 + ad)
	elif diff < 0:
		return acc * max(0.0, (1.0 - ad))
	return acc

func start_fight(enemies: Array, type: int):
	current_encounter = enemies
	enemy_count = enemies.size()
	fight_type = type
	queue_size = (enemy_count + 1) * (fight_type + 1)
	player_queue.clear()
	enemy_queue.clear()
	queue.clear()
	battle_start_time = GlobalDB.timer + battle_start_delay
	get_tree().change_scene_to_file("res://Scenes/combat.tscn")

func can_act() -> bool:
	return GlobalDB.timer >= battle_start_time

# Returns the queued action, or an empty array if the queue was full.
# Pass the returned value to free_action() to release the slot.
func add_action(author: int, input_id: String, type: int, index: int = 0) -> Array: # 1A 2S 3E 4C 5D
	var duration = 0.0
	if type == 2:
		duration = GlobalDB.spells(input_id).get("duration", 0.0)
	else:
		duration = 0.5
	duration *= action_speed_multiplier()
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

func free_action(action_or_side, index = null) -> void:
	# Accept either a queued action Array, or (is_player: bool, index: int).
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

func _actor_name(author: int, index: int) -> String:
	if author == 1:
		return "Player"
	if current_encounter.size() > index and index >= 0:
		var enemy = current_encounter[index]
		var enemy_data = GlobalDB.enemies(str(enemy))
		var enemy_name = enemy_data.get("name", "Enemy")
		return "%s %d" % [enemy_name, index + 1]
	return "Enemy %d" % [index + 1]

func _action_name(action: Array) -> String:
	var action_type = int(action[4])
	var input_id = str(action[3])
	if action_type == 1:
		if action[0] == 1:
			return GlobalDB.daggers(input_id).get("name", "Attack")
		return "Attack"
	var spell = GlobalDB.spells(input_id)
	return spell.get("name", "Spell")

func _target_name(action: Array) -> String:
	var is_player = action[0] == 1
	var target_index = int(action[6])
	if is_player:
		if current_encounter.size() > target_index and target_index >= 0:
			var enemy = current_encounter[target_index]
			var enemy_data = GlobalDB.enemies(str(enemy))
			var enemy_name = enemy_data.get("name", "Enemy")
			return "%s %d" % [enemy_name, target_index + 1]
		return "Enemy %d" % [target_index + 1]
	return "Player"

func queue_display() -> String:
	if queue.is_empty():
		return "<- Queue empty ->"
	var lines: Array = []
	for action in queue:
		var actor = _actor_name(int(action[0]), int(action[2]))
		var action_name = _action_name(action)
		var target = _target_name(action)
		lines.append("<- %s: %s => %s ->" % [actor, action_name, target])
	return "\n".join(lines)

func print_queue() -> void:
	print("[CombatQueue] %s" % queue_display())
func _process(_delta: float) -> void:
	var seconds_passed := int(floor(GlobalDB.timer))
	if seconds_passed == _last_printed_second:
		return
	_last_printed_second = seconds_passed
	print_queue()
