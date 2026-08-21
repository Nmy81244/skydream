extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player" or (body.get_parent() and body.get_parent().name == "Player"): 
		CombatLogic.start_fight(["001", "001"], 1)
		print("Fight started")
