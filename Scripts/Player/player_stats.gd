extends Node

var xp = 0
var level = 1

var pearls = 0

var gold = 0

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
	
func update_stats():
	while xp >= xp_for_level(level + 1) && level < 100:
		level += 1
		
	max_health = base_max_hp + ItemDB.tomes(tome)["health"] + ItemDB.charms(main_charm)["health"] + ItemDB.charms(sec_charm)["health"] + ItemDB.daggers(dagger)["health"] + ItemDB.souls(soul)["health"]
	max_mana = base_max_mp + ItemDB.tomes(tome)["mana"] + ItemDB.charms(main_charm)["mana"] + ItemDB.charms(sec_charm)["mana"] + ItemDB.daggers(dagger)["mana"] + ItemDB.souls(soul)["mana"]
		
	attack = base_attack + current_buffs.atk + ItemDB.tomes(tome)["attack"] + ItemDB.charms(main_charm)["attack"] + ItemDB.charms(sec_charm)["attack"] + ItemDB.daggers(dagger)["attack"] + ItemDB.souls(soul)["attack"]
	defense = base_defense + current_buffs.def + ItemDB.tomes(tome)["defense"] + ItemDB.charms(main_charm)["defense"] + ItemDB.charms(sec_charm)["defense"] + ItemDB.daggers(dagger)["defense"] + ItemDB.souls(soul)["defense"]
	speed = base_speed + current_buffs.spd + ItemDB.tomes(tome)["speed"] + ItemDB.charms(main_charm)["speed"] + ItemDB.charms(sec_charm)["speed"] + ItemDB.daggers(dagger)["speed"] + ItemDB.souls(soul)["speed"]
	
	power = base_power + current_buffs.pwr + ItemDB.tomes(tome)["power"] + ItemDB.charms(main_charm)["power"] + ItemDB.charms(sec_charm)["power"] + ItemDB.daggers(dagger)["power"] + ItemDB.souls(soul)["power"]
	accuracy = base_accuracy + current_buffs.acc + ItemDB.tomes(tome)["accuracy"] + ItemDB.charms(main_charm)["accuracy"] + ItemDB.charms(sec_charm)["accuracy"] + ItemDB.daggers(dagger)["accuracy"] + ItemDB.souls(soul)["accuracy"]
	crit = base_crit + current_buffs.crit + ItemDB.tomes(tome)["crit"] + ItemDB.charms(main_charm)["crit"] + ItemDB.charms(sec_charm)["crit"] + ItemDB.daggers(dagger)["crit"] + ItemDB.souls(soul)["crit"]
	
func _ready() -> void:
	update_stats()
