extends Node

var xp = 0
var level = 1
var pearls = 0
var base_stats = level_calc(level)

var health = 100;
var max_health = 100;
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
var base_speed = base_stats.base_spd
var speed = 0

var soul = "001"
var dagger = "000"
var tome = "000"
var main_charm = "001"
var sec_charm = "000"

var active_spells = []

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

const XP_MULT = 50.0

func xp_for_level(level: int) -> float:
	if level <= 1:
		return 0.0
	return XP_MULT * log(level) + xp_for_level(level - 1) + pow(level, 1.6)	

func level_calc(target_level: int) -> level_data:
	var result = level_data.new()
	result.level = target_level
	result.xp = xp_for_level(level)
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
	
func use_spell(spell_id: String):
	var spell = GlobalDB.spells(spell_id)
	var timestamp = GlobalDB.timer
	var duration = GlobalDB.spells(spell_id)["duration"]
	var delay = GlobalDB.spells(spell_id)["delay"]

	$CombatQueue.add_action(1, spell_id, 2)
	
	heal(-spell.health_cost)
	rest(-spell.mana_cost)
	if active_spells < $CombatQueue.queue_size/2:
		active_spells.append([spell_id, timestamp, duration, delay])
	
	
func update_stats():
	while xp >= xp_for_level(level + 1) && level < 100:
		level += 1
		
func _ready() -> void:
	max_health = base_max_hp + GlobalDB.tomes(tome)["health"] + GlobalDB.charms(main_charm)["health"] + GlobalDB.charms(sec_charm)["health"] + GlobalDB.daggers(dagger)["health"] + GlobalDB.souls(soul)["health"]
	max_mana = base_max_mp + GlobalDB.tomes(tome)["mana"] + GlobalDB.charms(main_charm)["mana"] + GlobalDB.charms(sec_charm)["mana"] + GlobalDB.daggers(dagger)["mana"] + GlobalDB.souls(soul)["mana"]
		
	attack = base_attack + current_buffs.atk + GlobalDB.tomes(tome)["attack"] + GlobalDB.charms(main_charm)["attack"] + GlobalDB.charms(sec_charm)["attack"] + GlobalDB.daggers(dagger)["attack"] + GlobalDB.souls(soul)["attack"]
	defense = base_defense + current_buffs.def + GlobalDB.tomes(tome)["defense"] + GlobalDB.charms(main_charm)["defense"] + GlobalDB.charms(sec_charm)["defense"] + GlobalDB.daggers(dagger)["defense"] + GlobalDB.souls(soul)["defense"]
	speed = base_speed + current_buffs.spd + GlobalDB.tomes(tome)["speed"] + GlobalDB.charms(main_charm)["speed"] + GlobalDB.charms(sec_charm)["speed"] + GlobalDB.daggers(dagger)["speed"] + GlobalDB.souls(soul)["speed"]
	
	power = base_power + current_buffs.pwr + GlobalDB.tomes(tome)["power"] + GlobalDB.charms(main_charm)["power"] + GlobalDB.charms(sec_charm)["power"] + GlobalDB.daggers(dagger)["power"] + GlobalDB.souls(soul)["power"]
	accuracy = base_accuracy + current_buffs.acc + GlobalDB.tomes(tome)["accuracy"] + GlobalDB.charms(main_charm)["accuracy"] + GlobalDB.charms(sec_charm)["accuracy"] + GlobalDB.daggers(dagger)["accuracy"] + GlobalDB.souls(soul)["accuracy"]
	crit = base_crit + current_buffs.crit + GlobalDB.tomes(tome)["crit"] + GlobalDB.charms(main_charm)["crit"] + GlobalDB.charms(sec_charm)["crit"] + GlobalDB.daggers(dagger)["crit"] + GlobalDB.souls(soul)["crit"]
	update_stats()

func _process(delta: float) -> void:
	mana += 0.2 * delta
	
	for spl in active_spells:
		if GlobalDB.timer >= active_spells[spl].timestamp + active_spells[spl].duration:
			active_spells.remove_at(spl)
			$CombatQueue.free_action(1, spl)
