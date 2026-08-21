extends Node

var fight_type = 1 # 1N 2U 3B 4S
var enemy_count = 0
var current_encounter: Array = []

var player_queue = []
var enemy_queue = []
var queue = []
var queue_size = 6

func start_fight(enemies: Array, type: int):
	current_encounter = enemies
	enemy_count = enemies.size()
	fight_type = type
	queue_size = (enemy_count + 1) * (fight_type + 1)
	get_tree().change_scene_to_file("res://Scenes/combat.tscn")

func add_action(author: int, input_id: String, type: int, index: int = 0): # 1A 2S 3E 4C 5D
	var duration = 0.0
	if type == 2:
		duration = GlobalDB.spells(input_id).get("duration", 0.0)
	elif type == 1:
		duration = 0.5
	else:
		duration = 0.5
	var ind = queue.size()
	var jnd = player_queue.size() if author else enemy_queue.size()
	var action = [author, ind, jnd, input_id, type, duration]

	if queue.size() < queue_size:
		if author:
			if player_queue.size() < queue_size/2:
				player_queue.append(action)
				queue.append(action)
		else:
			if enemy_queue.size() < queue_size/2:
				enemy_queue.append(action)
				queue.append(action)
	
func free_action(author: bool, index: int):
	if author:
		if index >= 0 and index < player_queue.size():
			var action = player_queue[index]
			player_queue.remove_at(index)
			queue.erase(action)
	else:
		if index >= 0 and index < enemy_queue.size():
			var action = enemy_queue[index]
			enemy_queue.remove_at(index)
			queue.erase(action)

func print_queue() -> void:
	print("[CombatQueue] Total: %d/%d | Player: %s | Enemy: %s" % [queue.size(), queue_size, str(player_queue), str(enemy_queue)])

func _process(delta: float) -> void:
	print_queue()
	pass
