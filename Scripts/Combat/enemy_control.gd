extends Node

var xp = 0
var level = 1
var pearls = 0

var enemies = []
var active_spells = []

var atk_spd: int = 0

class buffs:
	var atk = 0
	var def = 0
	var acc = 0
	var crit = 0
	var pwr = 0
	var spd = 0

var current_buffs = buffs.new()

var usable = true

func load_enemies(list: Array):
	for enemy in list:
		var enemy_data = GlobalDB.enemies(enemy).duplicate(true)
		enemy_data.buffs = buffs.new()
		enemies.append(enemy_data)

	update_stats()

func clear_enemies():
	enemies.clear()
	active_spells.clear()
	current_buffs = buffs.new()

func update_stats():
	for enemy in enemies:
		var base = GlobalDB.enemies(enemy.id)
		var b = enemy.get("buffs")
		if not b:
			b = buffs.new()
			enemy.buffs = b
		enemy.attack = base.attack + b.atk
		enemy.defense = base.defense + b.def
		enemy.speed = base.speed + b.spd
		enemy.atk_spd = base.atk_spd + b.spd
		enemy.power = base.power + b.pwr
		enemy.accuracy = base.accuracy + b.acc
		enemy.crit = base.crit + b.crit

func start_encounter(enemies_list: Array):
	clear_enemies()
	load_enemies(enemies_list)

func heal(hpwr: int, target: int):
	if target >= 0 and target < enemies.size():
		enemies[target].health += hpwr
		enemies[target].health = clamp(enemies[target].health, 0, enemies[target].max_health)

func rest(mrcv: int, target: int):
	if target >= 0 and target < enemies.size():
		enemies[target].mana += mrcv
		enemies[target].mana = clamp(enemies[target].mana, 0, enemies[target].max_mana)

func use_spell(spell_id: String, target: int):
	if not CombatLogic.can_act():
		return
	if target >= 0 and target < enemies.size():
		var enemy = enemies[target]
		var speed_multiplier = CombatLogic.action_speed_multiplier()
		
		if usable:
			if PlayerStats.has_method("use_enemy_spell"):
				PlayerStats.use_enemy_spell(spell_id, enemy.attack, enemy.power, enemy.crit, enemy.accuracy)
			else:
				var player_node = get_node_or_null("../Player")
				if player_node and player_node.has_method("use_enemy_spell"):
					player_node.use_enemy_spell(spell_id, enemy.attack, enemy.power, enemy.crit, enemy.accuracy)
			
			enemy.spell = GlobalDB.spells(spell_id)
			enemy.timestamp = GlobalDB.timer
			enemy.duration = (enemy.spell.get("duration", 0.0) / (1.0 + enemy.speed/20.0)) * speed_multiplier
			enemy.delay = (enemy.spell.get("cooldown", enemy.spell.get("delay", 0.0)) / (1.0 + enemy.speed/20.0)) * speed_multiplier
			enemy.applied_buffs = [
				enemy.spell.get("atk_boost", 0.0),
				enemy.spell.get("def_boost", 0.0),
				enemy.spell.get("acc_boost", 0.0),
				enemy.spell.get("crit_boost", 0.0),
				enemy.spell.get("spd_boost", 0.0)
			]

			if enemy.spell.get("element", 0.0) != 0:
				CombatLogic.add_action(0, spell_id, 2, target)

			heal(-int(enemy.spell.get("health_cost", 0.0)), target)
			rest(-int(enemy.spell.get("mana_cost", 0.0)), target)
			if active_spells.size() < CombatLogic.queue_size / 2:
				active_spells.append({
					"id": spell_id,
					"target": target,
					"timestamp": enemy.timestamp,
					"duration": enemy.duration,
					"delay": enemy.delay,
					"applied_buffs": enemy.applied_buffs
				})
				var b = enemy.get("buffs")
				if b:
					b.atk += enemy.applied_buffs[0]
					b.def += enemy.applied_buffs[1]
					b.acc += enemy.applied_buffs[2]
					b.crit += enemy.applied_buffs[3]
					b.spd += enemy.applied_buffs[4]
				update_stats()

func use_player_spell(spell_id: String, player_atk: int, player_pwr: int, player_crit: int, player_acc: int, target: int = 0) -> void:
	if target >= 0 and target < enemies.size():
		var enemy = enemies[target]
		var spell = GlobalDB.spells(spell_id)
		var spell_acc: float = spell.get("accuracy", 100.0)
		var spell_crit: float = spell.get("crit", 0.0)
		var spell_pwr: float = spell.get("power", 0.0)
		
		var hit_chance: float = player_acc + spell_acc - enemy.accuracy
		var gonna_hit: bool = randf_range(0, 100) <= hit_chance
		
		if gonna_hit:
			var crit_chance: float = player_crit + spell_crit
			if hit_chance > 100:
				crit_chance += (hit_chance - 100) * 0.5
			var gonna_crit: bool = randf_range(0, 100) <= crit_chance
			var crit_multiplier: float = 1.5 if gonna_crit else 1.0
			
			var damage_multiplier: float = CombatLogic.action_speed_multiplier()
			var raw_damage: float = (player_pwr + spell_pwr) * crit_multiplier * damage_multiplier
			var final_damage: int = int(max(1, raw_damage - enemy.defense))
			heal(-final_damage, target)

func use_attack(target: int = 0):
	if not CombatLogic.can_act():
		return
	if target >= 0 and target < enemies.size():
		var enemy = enemies[target]
		var speed_multiplier = CombatLogic.action_speed_multiplier()

		if usable:
			if PlayerStats.has_method("use_enemy_attack"):
				PlayerStats.use_enemy_attack(enemy.attack, enemy.crit, enemy.accuracy)
			else:
				var player_node = get_node_or_null("../Player")
				if player_node and player_node.has_method("use_enemy_attack"):
					player_node.use_enemy_attack(enemy.attack, enemy.crit, enemy.accuracy)
			
			enemy.timestamp = GlobalDB.timer
			enemy.duration = (0.5 / (1.0 + enemy.speed/20.0)) * speed_multiplier
			enemy.delay = (1.0 / (1.0 + enemy.atk_spd/10.0)) * speed_multiplier
			
			CombatLogic.add_action(0, "000", 1, target)
			if active_spells.size() < CombatLogic.queue_size / 2:
				active_spells.append({
					"id": "000",
					"target": target,
					"timestamp": enemy.timestamp,
					"duration": enemy.duration,
					"delay": enemy.delay,
					"applied_buffs": [0.0, 0.0, 0.0, 0.0, 0.0]
				})

func use_player_attack(player_atk: int, player_crit: int, player_acc: int, target: int = 0) -> void:
	if target >= 0 and target < enemies.size():
		var enemy = enemies[target]
		var player_node = get_node_or_null("../Player")
		var dagger_id = player_node.dagger if (player_node and "dagger" in player_node) else "001"
		var dagger_data = GlobalDB.daggers(dagger_id)
		var dagger_acc = dagger_data.get("accuracy", 90.0)
		var dagger_crit = dagger_data.get("crit", 6.0)
		var dagger_atk = dagger_data.get("attack", 7.0)

		var hit_chance: float = player_acc + dagger_acc - enemy.accuracy
		var gonna_hit: bool = randf_range(0, 100) <= hit_chance

		if gonna_hit:
			var crit_chance: float = player_crit + dagger_crit
			if hit_chance > 100:
				crit_chance += (hit_chance - 100) * 0.5
			var gonna_crit: bool = randf_range(0, 100) <= crit_chance
			var crit_multiplier: float = 1.5 if gonna_crit else 1.0

			var damage_multiplier: float = CombatLogic.action_speed_multiplier()
			var raw_damage: float = (player_atk + dagger_atk) * crit_multiplier * damage_multiplier
			var final_damage: int = int(max(1, raw_damage - enemy.defense))
			heal(-final_damage, target)

func _ready() -> void:
	if CombatLogic.current_encounter.size() > 0:
		start_encounter(CombatLogic.current_encounter)
	elif enemies.size() == 0:
		start_encounter(["001", "001"])

	match enemies.size():
		1:
			$"1/Enemy1".play(enemies[0].id)
		2:
			$"2/Enemy1".play(enemies[0].id)
			$"2/Enemy2".play(enemies[1].id)
		3:
			$"3/Enemy1".play(enemies[0].id)
			$"3/Enemy2".play(enemies[1].id)
			$"3/Enemy3".play(enemies[2].id)
		4:
			$"4/Enemy1".play(enemies[0].id)
			$"4/Enemy2".play(enemies[1].id)
			$"4/Enemy3".play(enemies[2].id)
			$"4/Enemy4".play(enemies[3].id)
	update_stats()

func _process(delta: float) -> void:
	for i in range(enemies.size()):
		enemies[i].mana += 0.025 * delta
		enemies[i].mana = clamp(enemies[i].mana, 0, enemies[i].max_mana)
	
	usable = true
	for i in range(active_spells.size() - 1, -1, -1):
		var spl = active_spells[i]
		if spl.target >= 0 and spl.target < enemies.size():
			var enemy = enemies[spl.target]
			var spd_fx = 1.0 + (enemy.speed / 100.0)
			if GlobalDB.timer < spl.timestamp + spl.delay * spd_fx:
				usable = false
			if GlobalDB.timer >= spl.timestamp + spl.duration * spd_fx:
				var b = enemy.get("buffs")
				if b:
					b.atk -= spl.applied_buffs[0]
					b.def -= spl.applied_buffs[1]
					b.acc -= spl.applied_buffs[2]
					b.crit -= spl.applied_buffs[3]
					b.spd -= spl.applied_buffs[4]
				active_spells.remove_at(i)
				CombatLogic.free_action(false, i)
				update_stats()
		else:
			active_spells.remove_at(i)
			CombatLogic.free_action(false, i)
			update_stats()
