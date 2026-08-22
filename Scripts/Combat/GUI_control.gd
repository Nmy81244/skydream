extends Control

var player_label: Label = null
var queue_label: Label = null

func _find_stats_node(start: Node) -> Node:
	# Recursively search for a node that exposes health/max_health/mana/max_mana
	if start == null:
		return null
	if "health" in start and "max_health" in start and "mana" in start and "max_mana" in start:
		return start
	for child in start.get_children():
		var found = _find_stats_node(child)
		if found:
			return found
	return null

func _player_stats() -> Dictionary:
	# 1) Direct autoload/global variable
	if typeof(PlayerStats) != TYPE_NIL:
		var ps = PlayerStats
		if ps and "health" in ps and "max_health" in ps and "mana" in ps and "max_mana" in ps:
			return {
				"health": float(ps.health),
				"max_health": float(ps.max_health),
				"mana": float(ps.mana),
				"max_mana": float(ps.max_mana),
			}
	# 2) /root/PlayerStats node
	var root_ps = get_node_or_null("/root/PlayerStats")
	if root_ps and "health" in root_ps and "max_health" in root_ps and "mana" in root_ps and "max_mana" in root_ps:
		return {
			"health": float(root_ps.health),
			"max_health": float(root_ps.max_health),
			"mana": float(root_ps.mana),
			"max_mana": float(root_ps.max_mana),
		}
	# 3) Search current scene for a node with stats
	var scene = get_tree().get_current_scene()
	if scene:
		var found = _find_stats_node(scene)
		if found:
			return {
				"health": float(found.health),
				"max_health": float(found.max_health),
				"mana": float(found.mana),
				"max_mana": float(found.max_mana),
			}
	# Last-resort defaults
	return {
		"health": 100.0,
		"max_health": 100.0,
		"mana": 80.0,
		"max_mana": 80.0,
	}

var _last_debug_second := -1

func _ready() -> void:
	# Resolve label nodes defensively. Support running as an autoload/singleton or as a Control in the scene.
	var root = get_tree().get_root()
	# find_node(name, recursive=true, owned=true) - search entire tree for nodes named Player_Perc / Queue
	var node_p = root.find_node("Player_Perc", true, false)
	if node_p and node_p is Label:
		player_label = node_p as Label
	else:
		player_label = null
	var node_q = root.find_node("Queue", true, false)
	if node_q and node_q is Label:
		queue_label = node_q as Label
	else:
		queue_label = null

	if player_label:
		player_label.visible = true
		player_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	else:
		print("GUI_WARNING: Player_Perc label not found (searched entire tree)")
	if queue_label:
		queue_label.visible = true
		queue_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		queue_label.horizontal_alignment = 0
		queue_label.vertical_alignment = 0
		queue_label.autowrap = true
	else:
		print("GUI_WARNING: Queue label not found (searched entire tree)")

func _process(_delta: float) -> void:
	var stats = _player_stats()
	var hp = int(stats["health"])
	var mhp = int(stats["max_health"])
	var mp = int(stats["mana"])
	var mmp = int(stats["max_mana"])
	var queue_text = CombatLogic.queue_display() if CombatLogic.has_method("queue_display") else "<- Queue empty ->"
	if player_label:
		player_label.text = "HP: %d/%d\nMP: %d/%d" % [hp, mhp, mp, mmp]
	else:
		# Try to resolve it at runtime if missing
		var _node = get_node_or_null("Player_Perc")
		if _node == null:
			_node = get_node_or_null("UI/Control/Player_Perc")
		if _node == null:
			var _scene = get_tree().get_current_scene()
			_node = _scene.get_node_or_null("Player_Perc") if _scene else null
		player_label = _node
		if player_label:
			player_label.text = "HP: %d/%d\nMP: %d/%d" % [hp, mhp, mp, mmp]
	if queue_label:
		queue_label.text = queue_text if not queue_text.is_empty() else "<- Queue empty ->"
	else:
		var _qnode = get_node_or_null("Queue")
		if _qnode == null:
			_qnode = get_node_or_null("UI/Control/Queue")
		if _qnode == null:
			var _scene = get_tree().get_current_scene()
			_qnode = _scene.get_node_or_null("Queue") if _scene else null
		queue_label = _qnode
		if queue_label:
			queue_label.text = queue_text if not queue_text.is_empty() else "<- Queue empty ->"

	# Debug log once per second so user can see what values the GUI reads
	if typeof(GlobalDB) != TYPE_NIL:
		var seconds_passed := int(floor(GlobalDB.timer))
		if seconds_passed != _last_debug_second:
			_last_debug_second = seconds_passed
			# Also print where stats were found
			var source = "default"
			if typeof(PlayerStats) != TYPE_NIL:
				source = "global_PlayerStats"
			elif get_node_or_null("/root/PlayerStats"):
				source = "/root/PlayerStats"
			else:
				var scene = get_tree().get_current_scene()
				var found = scene and _find_stats_node(scene)
				if found:
					source = str(found.get_path())
			print("GUI_DEBUG: stats_read= hp=%d mhp=%d mp=%d mmp=%d | source=%s" % [hp, mhp, mp, mmp, source])
