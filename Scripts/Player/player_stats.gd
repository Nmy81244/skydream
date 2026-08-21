extends Node

var health = 100;
var max_health = 100;
var base_max_hp = base_stats.base_hp
var mana = 80
var max_mana = 80
var base_max_mp = base_stats.base_mp

var xp = 0
var level = 1
var gold = 0
var base_stats = level_calc(level)

var base_attack = base_stats.base_atk
var attack = 0
var base_defense = base_stats.base_def
var defense = 0
var base_power = base_stats.base_pow
var power = 0
var base_accuracy = base_stats.base_acc
var accuracy = 0
var base_crit = base_stats.base_crit
var crit

var soul = "001"
var dagger = "000"
var tome = "000"
var main_charm = "001"
var sec_charm = "000"

class level_data:
	var level
	var xp
	var base_hp
	var base_mp
	var base_atk
	var base_def
	var base_pow
	var base_acc
	var base_crit

class buffs:
	var atk = 0
	var def = 0
	var acc = 0
	var crit = 0
	var pow = 0
	
	
var current_buffs = buffs.new()

const XP_MULT = 50.0  # ajustá a gusto para controlar qué tan empinada es la curva

func xp_for_level(level: int) -> float:
	if level <= 1:
		return 0.0
	return XP_MULT * log(level) + xp_for_level(level - 1)

func level_calc(target_level: int) -> level_data:
	var result = level_data.new()
	result.level = target_level
	result.xp = xp_for_level(level)
	result.base_hp = 100 + round(20*log(target_level))
	result.base_mp = 80 + round(16*log(target_level))
	result.base_atk = round(3.5*log(target_level))
	result.base_def = round(4*log(target_level))
	result.base_pow = round(2.5*log(target_level))
	result.base_acc = round(4*log(target_level))
	result.base_crit = round(0.5*log(target_level))
	
	return result
	
func update_stats():
	while xp >= xp_for_level(level + 1):
		level += 1
		
	attack = base_attack + current_buffs.atk + ItemDB.tomes(tome)["attack"] + ItemDB.charms(main_charm)["attack"] + ItemDB.charms(sec_charm)["attack"] + ItemDB.daggers(dagger)["attack"] + ItemDB.souls(soul)["attack"]
	defense = base_defense + current_buffs.def + ItemDB.tomes(tome)["defense"] + ItemDB.charms(main_charm)["defense"] + ItemDB.charms(sec_charm)["defense"] + ItemDB.daggers(dagger)["defense"] + ItemDB.souls(soul)["defense"]
	
	power = base_power + current_buffs.pow + ItemDB.tomes(tome)["power"] + ItemDB.charms(main_charm)["power"] + ItemDB.charms(sec_charm)["power"] + ItemDB.daggers(dagger)["power"] + ItemDB.souls(soul)["power"]
	accuracy = base_accuracy + current_buffs.acc + ItemDB.tomes(tome)["accuracy"] + ItemDB.charms(main_charm)["accuracy"] + ItemDB.charms(sec_charm)["accuracy"] + ItemDB.daggers(dagger)["accuracy"] + ItemDB.souls(soul)["accuracy"]
	crit = base_crit + current_buffs.crit + ItemDB.tomes(tome)["crit"] + ItemDB.charms(main_charm)["crit"] + ItemDB.charms(sec_charm)["crit"] + ItemDB.daggers(dagger)["crit"] + ItemDB.souls(soul)["crit"]
	
	
	
		
