extends Node

var fight_type = 1; #1N 2U 3B 4S
var enemy_count = 0

var player_queue = []
var enemy_queue = []
var queue = []
var queue_size = 0

func start_fight(enemy_num: int, type: int):
	enemy_count = enemy_num
	fight_type = type
	
	queue_size = (enemy_count + 1) * (fight_type + 1)

func add_action(author: int, input_id: String, type: int): # 1A 2S 3E 4C 5D
	var action = [author, input_id, type]
	
	if author == 0 && type == 2:
		PlayerStats.use_spell(input_id)
	if author == 1 && type == 2:
		$Enemies.use_spell(action)

	if queue.size() < queue_size:
		if author:
			if player_queue.size() < queue_size/2:
				player_queue.append(action)
		else:
			if enemy_queue.size() < queue_size/2:
				enemy_queue.append(action)
	queue.append(action)

func free_action(author: bool, index: int):
	if author:
		player_queue.remove_at(index)
	else:
		enemy_queue.remove_at(index)
	
	
