extends Node

var xp = 0
var level = 1
var pearls = 0
var base_stats = level_calc(level)

var health = 100
var max_health = 100
var base_max_hp = base_stats.base_hp
var mana = 80
var max_mana = 80
var base_max_mp = base_stats.base_mp

var base_attack = base_stats.base_atk
var attack = 0
var base_defense = base_stats.base_def
var defense = 0
var base_power = base_stats.base_pwr
var power = 0
var base_accuracy = base_stats.base_acc
var accuracy = 0
var base_crit = base_stats.base_crit
var crit = 0
var base_atk_spd = base_stats.base_spd
var atk_spd = 0
var base_speed = base_stats.base_spd
var speed = 0

var soul = "001"
var dagger = "001"
var tome = "001"
var main_charm = "001"
var sec_charm = "000"

var active_spells = []
var active_enemy_spells = []

class level_data:
	var level
	var xp
	var base_hp = 100
	var base_mp = 80

	var base_atk = 0
	var base_def = 0
	var base_pwr = 0
	var base_acc = 0
	var base_crit = 3
	var base_spd = 0

class buffs:
	var atk = 0
	var def = 0
	var acc = 0
	var crit = 0
	var pwr = 0
	var spd = 0
	
var current_buffs = buffs.new()

var usable = true

const XP_MULT = 50.0

func xp_for_level(level: int) -> float:
	if level <= 1:
		return 0.0
	return XP_MULT * log(level) + xp_for_level(level - 1) + pow(level, 1.6)	

func level_calc(target_level: int) -> level_data:
	var result = level_data.new()
	result.level = target_level
	result.xp = xp_for_level(target_level)
	result.base_hp += round(80*log(target_level))
	result.base_mp += round(64*log(target_level))
	result.base_atk += round(15*log(target_level))
	result.base_def += round(16*log(target_level))
	result.base_pwr += round(10*log(target_level))
	result.base_acc += round(16*log(target_level))
	result.base_spd += round(8*log(target_level))
	result.base_crit += round(2*log(target_level))
	
	return result
	
func heal(hpwr: int):
	health += hpwr
	health = clamp(health, 0, max_health)
	
func rest(mrcv: int):
	mana += mrcv
	mana = clamp(mana, 0, max_mana)
	
func use_spell(spell_id: String, target: int = 0):
	var spell = GlobalDB.spells(spell_id)
	var timestamp = GlobalDB.timer
	var duration = spell.get("duration", 0.0)
	var delay = spell.get("cooldown", spell.get("delay", 0.0))
	var applied_buffs = [
		spell.get("atk_boost", 0.0),
		spell.get("def_boost", 0.0),
		spell.get("acc_boost", 0.0),
		spell.get("crit_boost", 0.0),
		spell.get("spd_boost", 0.0)
	]
	
	if usable:
		var enemies_node = get_node_or_null("../Enemies")
		if enemies_node and enemies_node.has_method("use_player_spell"):
			enemies_node.use_player_spell(spell_id, attack, power, crit, accuracy, target)

		if spell.get("element", 0.0) != 0:
			CombatLogic.add_action(1, spell_id, 2, target)
		
		heal(-int(spell.get("health_cost", 0.0)))
		rest(-int(spell.get("mana_cost", 0.0)))
		if active_spells.size() < CombatLogic.queue_size / 2:
			active_spells.append({
				"id": spell_id,
				"timestamp": timestamp,
				"duration": duration,
				"delay": delay,
				"applied_buffs": applied_buffs
			})
			current_buffs.atk += applied_buffs[0]
			current_buffs.def += applied_buffs[1]
			current_buffs.acc += applied_buffs[2]
			current_buffs.crit += applied_buffs[3]
			current_buffs.spd += applied_buffs[4]
			update_stats()

func use_enemy_spell(spell_id: String, enemy_atk: int, enemy_pwr: int, enemy_crit: int, enemy_acc: int) -> void:
	var spell = GlobalDB.spells(spell_id)
	var spell_acc: float = spell.get("accuracy", 100.0)
	var spell_crit: float = spell.get("crit", 0.0)
	var spell_pwr: float = spell.get("power", 0.0)
	
	var hit_chance: float = enemy_acc + spell_acc - accuracy
	var gonna_hit: bool = randf_range(0, 100) <= hit_chance
	
	if gonna_hit:
		var crit_chance: float = enemy_crit + spell_crit
		if hit_chance > 100:
			crit_chance += (hit_chance - 100) * 0.5
		var gonna_crit: bool = randf_range(0, 100) <= crit_chance
		var crit_multiplier: float = 1.5 if gonna_crit else 1.0
		
		var raw_damage: float = (enemy_pwr + spell_pwr) * crit_multiplier
		var final_damage: int = int(max(1, raw_damage - defense))
		heal(-final_damage)

func use_attack(target: int = 0):
	if usable:
		var enemies_node = get_node_or_null("../Enemies")
		if enemies_node and enemies_node.has_method("use_player_attack"):
			enemies_node.use_player_attack(attack, crit, accuracy, target)
		
		var timestamp = GlobalDB.timer
		var duration = 0.5 / (1.0 + speed / 20.0)
		var delay = 1.0 / (1.0 + atk_spd / 10.0)
		
		CombatLogic.add_action(1, dagger, 1, target)
		if active_spells.size() < CombatLogic.queue_size / 2:
			active_spells.append({
				"id": dagger,
				"timestamp": timestamp,
				"duration": duration,
				"delay": delay,
				"applied_buffs": [0.0, 0.0, 0.0, 0.0, 0.0]
			})

func use_enemy_attack(enemy_atk: int, enemy_crit: int, enemy_acc: int) -> void:
	var hit_chance: float = enemy_acc + 90.0 - accuracy
	var gonna_hit: bool = randf_range(0, 100) <= hit_chance
	
	if gonna_hit:
		var crit_chance: float = enemy_crit + 3.0
		if hit_chance > 100:
			crit_chance += (hit_chance - 100) * 0.5
		var gonna_crit: bool = randf_range(0, 100) <= crit_chance
		var crit_multiplier: float = 1.5 if gonna_crit else 1.0
		
		var raw_damage: float = (enemy_atk + 5.0) * crit_multiplier
		var final_damage: int = int(max(1, raw_damage - defense))
		heal(-final_damage)
		
func update_stats():
	while xp >= xp_for_level(level + 1) and level < 100:
		level += 1
		base_stats = level_calc(level)
		base_max_hp = base_stats.base_hp
		base_max_mp = base_stats.base_mp
		base_attack = base_stats.base_atk
		base_defense = base_stats.base_def
		base_power = base_stats.base_pwr
		base_accuracy = base_stats.base_acc
		base_crit = base_stats.base_crit
		base_atk_spd = base_stats.base_spd
		base_speed = base_stats.base_spd

	max_health = base_max_hp + GlobalDB.tomes(tome)["health"] + GlobalDB.charms(main_charm)["health"] + GlobalDB.charms(sec_charm)["health"] + GlobalDB.daggers(dagger)["health"] + GlobalDB.souls(soul)["health"]
	max_mana = base_max_mp + GlobalDB.tomes(tome)["mana"] + GlobalDB.charms(main_charm)["mana"] + GlobalDB.charms(sec_charm)["mana"] + GlobalDB.daggers(dagger)["mana"] + GlobalDB.souls(soul)["mana"]
		
	attack = base_attack + current_buffs.atk + GlobalDB.tomes(tome)["attack"] + GlobalDB.charms(main_charm)["attack"] + GlobalDB.charms(sec_charm)["attack"] + GlobalDB.daggers(dagger)["attack"] + GlobalDB.souls(soul)["attack"]
	defense = base_defense + current_buffs.def + GlobalDB.tomes(tome)["defense"] + GlobalDB.charms(main_charm)["defense"] + GlobalDB.charms(sec_charm)["defense"] + GlobalDB.daggers(dagger)["defense"] + GlobalDB.souls(soul)["defense"]
	speed = base_speed + current_buffs.spd + GlobalDB.tomes(tome)["speed"] + GlobalDB.charms(main_charm)["speed"] + GlobalDB.charms(sec_charm)["speed"] + GlobalDB.daggers(dagger)["speed"] + GlobalDB.souls(soul)["speed"]
	atk_spd = base_atk_spd + current_buffs.spd + GlobalDB.daggers(dagger)["atk_spd"]
	power = base_power + current_buffs.pwr + GlobalDB.tomes(tome)["power"] + GlobalDB.charms(main_charm)["power"] + GlobalDB.charms(sec_charm)["power"] + GlobalDB.daggers(dagger)["power"] + GlobalDB.souls(soul)["power"]
	accuracy = base_accuracy + current_buffs.acc + GlobalDB.tomes(tome)["accuracy"] + GlobalDB.charms(main_charm)["accuracy"] + GlobalDB.charms(sec_charm)["accuracy"] + GlobalDB.daggers(dagger)["accuracy"] + GlobalDB.souls(soul)["accuracy"]
	crit = base_crit + current_buffs.crit + GlobalDB.tomes(tome)["crit"] + GlobalDB.charms(main_charm)["crit"] + GlobalDB.charms(sec_charm)["crit"] + GlobalDB.daggers(dagger)["crit"] + GlobalDB.souls(soul)["crit"]

func get_spells() -> Array:
	var spells = []
	for i in range(1, 10):
		var spell_id = soul + tome + str(i)
		if GlobalDB.spells_data.has(spell_id):
			spells.append(GlobalDB.spells(spell_id))
	return spells
	

func _ready() -> void:
	update_stats()
	health = max_health
	mana = max_mana

func _process(delta: float) -> void:
	#print(health)
	var spd_fx = 1+(speed/10)
	mana += 0.025 * delta
	mana = clamp(mana, 0, max_mana)
	
	usable = true
	for i in range(active_spells.size() - 1, -1, -1):
		var spl = active_spells[i]
		if GlobalDB.timer < spl.timestamp + spl.delay * spd_fx:
			usable = false
		if GlobalDB.timer >= spl.timestamp + spl.duration * spd_fx:
			current_buffs.atk -= spl.applied_buffs[0]
			current_buffs.def -= spl.applied_buffs[1]
			current_buffs.acc -= spl.applied_buffs[2]
			current_buffs.crit -= spl.applied_buffs[3]
			current_buffs.spd -= spl.applied_buffs[4]
			active_spells.remove_at(i)
			CombatLogic.free_action(true, i)
			update_stats()
			
	for i in range(active_enemy_spells.size() - 1, -1, -1):
		var spl = active_enemy_spells[i]
		if GlobalDB.timer >= spl.timestamp + spl.duration:
			current_buffs.atk -= spl.applied_buffs[0]
			current_buffs.def -= spl.applied_buffs[1]
			current_buffs.acc -= spl.applied_buffs[2]
			current_buffs.crit -= spl.applied_buffs[3]
			current_buffs.spd -= spl.applied_buffs[4]
			active_enemy_spells.remove_at(i)
			update_stats()
