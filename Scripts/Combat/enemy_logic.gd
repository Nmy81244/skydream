extends Node

var enemies = $Enemies.enemies
var queue = $CombatQueue.queue
var enemy_queue = $CombatQueue.enemy_queue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for enemy in enemies:
		ai_logic(ItemDB.enemies(enemy)["id"], 0)
		
	pass
	
func ai_logic(enemy: String, index: int):
	var enemy_char = enemies[index]
	
	match enemy:
		"001":
			if enemy_char.mp
			
	pass
