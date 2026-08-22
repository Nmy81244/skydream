extends Control

@onready var label: Label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = "%d/%d\n%d/%d" % [
		PlayerStats.health, PlayerStats.max_health,
		PlayerStats.mana, PlayerStats.max_mana
	]
