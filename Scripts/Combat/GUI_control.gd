extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$Label.text = PlayerStats.health + "/" + PlayerStats.max_health + "\n" + PlayerStats.mana + "/" + PlayerStats.max_mana
	
	pass
