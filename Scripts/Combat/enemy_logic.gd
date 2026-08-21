extends Node

var enemies = []
var queue = []
var enemy_queue = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = $Enemies.enemies
	queue = $CombatQueue.queue
	enemy_queue = $CombatQueue.enemy_queue
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for enemy in enemies:
		ai_logic(enemies[enemy].id, enemy)
		
	pass
	
func ai_logic(enemy: String, index: int):
	var enemy_char = enemies[index]
	
	match enemy:
		"001":
			if enemy_char.mana == 80:
				$CombatQueue.add_action(0, "101801", 2)
			
	pass
