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

# Some root types (Window) don't implement find_node; use recursive search helper instead
func _find_label_by_name(start: Node, target_name: String) -> Label:
	if start == null:
		return null
	if start.name == target_name and start is Label:
		return start as Label
	for child in start.get_children():
		var found = _find_label_by_name(child, target_name)
		if found:
			return found
	return null

func _ready() -> void:
	# Resolve label nodes defensively. Support running as an autoload/singleton or as a Control in the scene.
	var root = get_tree().get_root()
	var node_p = _find_label_by_name(root, "Player_Perc")
	player_label = node_p
	var node_q = _find_label_by_name(root, "Queue")
	queue_label = node_q

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

func _ensure_labels() -> void:
	# Ensure player_label and queue_label reference valid Label instances attached to the scene tree.
	if player_label and is_instance_valid(player_label) and player_label.is_inside_tree():
		pass
	else:
		# search current scene first (more specific), then root
		var scene = get_tree().get_current_scene()
		var found = scene and _find_label_by_name(scene, "Player_Perc")
		if found:
			player_label = found
		else:
			var root = get_tree().get_root()
			player_label = _find_label_by_name(root, "Player_Perc")
		# apply visual defaults
		if player_label:
			player_label.visible = true
			player_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

	if queue_label and is_instance_valid(queue_label) and queue_label.is_inside_tree():
		pass
	else:
		var scene = get_tree().get_current_scene()
		var found_q = scene and _find_label_by_name(scene, "Queue")
		if found_q:
			queue_label = found_q
		else:
			var root = get_tree().get_root()
			queue_label = _find_label_by_name(root, "Queue")
		if queue_label:
			queue_label.visible = true
			queue_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			queue_label.horizontal_alignment = 0
			queue_label.vertical_alignment = 0
			queue_label.autowrap = true

func _process(_delta: float) -> void:
	# make sure labels are valid before trying to update them
	_ensure_labels()
	var stats = _player_stats()
	var hp = int(stats["health"])
	var mhp = int(stats["max_health"])
	var mp = int(stats["mana"])
	var mmp = int(stats["max_mana"])
	var queue_text = CombatLogic.queue_display() if CombatLogic.has_method("queue_display") else "<- Queue empty ->"
	if player_label:
		player_label.text = "HP: %d/%d\nMP: %d/%d" % [hp, mhp, mp, mmp]
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
