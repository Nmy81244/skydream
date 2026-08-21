extends Node

var enemies = []
var enemy_cooldowns: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = $Enemies.enemies
	enemy_cooldowns.clear()
	for i in range(enemies.size()):
		enemy_cooldowns.append(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	while enemy_cooldowns.size() < enemies.size():
		enemy_cooldowns.append(0.0)
		
	for enemy_i in range(enemies.size()):
		if enemy_cooldowns[enemy_i] > 0.0:
			enemy_cooldowns[enemy_i] -= delta
		else:
			ai_logic(enemies[enemy_i].id, enemy_i)
	
func ai_logic(enemy: String, index: int):
	var enemy_char = enemies[index]
	var spells = enemy_char.get("spells", [])
	if spells.is_empty():
		spells = GlobalDB.enemies(enemy).get("spells", ["101801"])
	var spell_id = spells[0] if spells.size() > 0 else "101801"
	var spell = GlobalDB.spells(spell_id)
	var mana_cost = spell.get("mana_cost", 0.0)
	
	var player_node = get_node_or_null("Player")
	var player_health = player_node.health if (player_node and "health" in player_node) else 100
	
	match enemy:
		"001":
			if player_health <= 50 and CombatLogic.enemy_queue.size() < CombatLogic.queue_size / 2:
				$Enemies.use_attack(index)
				enemy_cooldowns[index] = 1.0 / (1.0 + enemy_char.get("atk_spd", 0.0) / 10.0)

			if enemy_char.mana >= mana_cost and CombatLogic.enemy_queue.size() < CombatLogic.queue_size / 2:
				$Enemies.use_spell(spell_id, index)
				enemy_cooldowns[index] = spell.get("cooldown", spell.get("delay", 2.0))
