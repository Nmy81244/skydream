extends Node

var enemies = []

class stats_data:
	var level
	var xp
	var pearls

class buffs:
	var hp = 0
	var mp = 0
	var atk = 0
	var def = 0
	var acc = 0
	var crit = 0
	var pwr = 0
	var spd = 0
	
	
var current_buffs = buffs.new()

func heal(target: int, hpwr: int):
	enemies[target].health += hpwr
	enemies[target].health = clamp(enemies[target].health, 0, enemies[target].max_health)
	
func rest(target: int, mrcv: int):
	enemies[target].mana += mrcv
	enemies[target].mana = clamp(enemies[target].mana, 0, enemies[target].max_mana)
	
func load_enemies(list: Array):
	for enemy in list:
		enemies.append(ItemDB.enemies(enemy))
		
	update_stats();
	
func clear_enemies():
	enemies.clear()
	current_buffs = buffs.new()

func update_stats():
	for enemy in enemies:
		enemy.max_health += current_buffs.hp
		enemy.max_mana += current_buffs.mp
			
		enemy.attack += current_buffs.atk
		enemy.defense += current_buffs.def
		enemy.speed += current_buffs.spd
		
		enemy.power += current_buffs.pwr
		enemy.accuracy += current_buffs.acc
		enemy.crit += current_buffs.crit
		

func _ready() -> void:
	load_enemies(["001"])
	
	match enemies.size():
		1:
			$"1/AnimatedSprite2D".play(enemies[0].id)
	update_stats()
