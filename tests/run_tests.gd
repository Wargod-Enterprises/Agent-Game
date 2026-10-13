extends Node
## Automated checks for the foundation. Run from the project folder:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/run_tests.tscn
## Exits with code 1 if anything fails.

const TOWER := "res://levels/missions/tower_test.tscn"
const HUB := "res://levels/hub/hub_street.tscn"
const TEST_SAVE := "user://test_save.json"

var _failures := 0
var _game_state: Node
var _events: Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_game_state = get_tree().root.get_node("GameState")
	_events = get_tree().root.get_node("Events")
	_game_state.save_path = TEST_SAVE
	_game_state.reset()

	_test_upgrades()
	_test_save_and_load()
	await _test_sight()
	await _test_hearing()
	await _test_scan()
	await _test_ladder()
	await _test_hub()

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("\n%s" % ("ALL TESTS PASSED" if _failures == 0 else "%d FAILED" % _failures))
	get_tree().quit(1 if _failures > 0 else 0)


func _check(ok: bool, what: String) -> void:
	print(("  PASS  " if ok else "  FAIL  ") + what)
	if not ok:
		_failures += 1


func _test_upgrades() -> void:
	print("Upgrades")
	var gs = _game_state
	_check(gs.get_stat("badge", "scan_radius") == 96.0, "badge starts with scan radius 96")
	_check(not gs.unlock("badge", "wide_scan_1"), "can't unlock with 0 skill points")
	gs.skill_points = 3
	_check(not gs.unlock("badge", "wide_scan_2"), "can't skip a required upgrade")
	_check(gs.unlock("badge", "wide_scan_1"), "unlock Wide Scan I")
	_check(gs.get_stat("badge", "scan_radius") == 128.0, "Wide Scan I adds 32 radius")
	_check(gs.unlock("badge", "wide_scan_2") and gs.skill_points == 0, "Wide Scan II costs 2")
	_check(gs.get_stat("weapon", "beam_damage") == 1.0, "other devices are unaffected")
	gs.complete_mission("m1")
	gs.complete_mission("m1")
	_check(gs.skill_points == 1, "a mission pays a skill point only once")


func _test_save_and_load() -> void:
	print("Save and load")
	var gs = _game_state
	gs.save_game()
	gs.reset()
	_check(not gs.has_upgrade("badge", "wide_scan_2"), "reset clears upgrades")
	gs.load_game()
	_check(gs.has_upgrade("badge", "wide_scan_2"), "upgrades come back after loading")
	_check(gs.skill_points == 1 and gs.completed_missions.has("m1"), "points and missions come back")
	gs.reset()


## Loads the tower mission, puts the Agent somewhere, runs `frames` physics
## steps and returns the level (caller frees it).
func _tower_with_agent_at(pos: Vector2, frames: int) -> Node:
	var level: Node = load(TOWER).instantiate()
	level.get_node("Agent").position = pos
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	for i in frames:
		await get_tree().physics_frame
	return level


func _guard_state(level: Node) -> int:
	return level.get_node("Guard").awareness.state


func _test_sight() -> void:
	print("Guard sight (side view)")
	var cases := [
		["Agent on the floor in front -> alert", Vector2(300, 228), Awareness.State.ALERT],
		["Agent on the walkway above -> unaware", Vector2(280, 160), Awareness.State.UNAWARE],
		["Agent behind the guard -> unaware", Vector2(160, 228), Awareness.State.UNAWARE],
	]
	for c in cases:
		var level: Node = await _tower_with_agent_at(c[1], 60)
		_check(_guard_state(level) == c[2], c[0])
		level.free()
	var level: Node = await _tower_with_agent_at(Vector2(300, 228), 5)
	_check(_guard_state(level) != Awareness.State.ALERT, "a glimpse isn't instant detection")
	level.free()


func _test_hearing() -> void:
	print("Guard hearing")
	var level: Node = await _tower_with_agent_at(Vector2(195, 228), 2)
	var agent: Agent = level.get_node("Agent")
	agent.make_noise(agent.run_noise_radius)
	_check(_guard_state(level) == Awareness.State.SUSPICIOUS, "a nearby footstep makes the guard suspicious")
	level.free()
	level = await _tower_with_agent_at(Vector2(40, 228), 2)
	agent = level.get_node("Agent")
	agent.make_noise(agent.run_noise_radius)
	_check(_guard_state(level) == Awareness.State.UNAWARE, "a far-away footstep goes unheard")
	level.free()


func _test_scan() -> void:
	print("Scanner")
	var level: Node = await _tower_with_agent_at(Vector2(200, 228), 2)
	var agent: Agent = level.get_node("Agent")
	var guard_tag: Scannable = level.get_node("Guard/Scannable")
	_check(agent.scanner.try_scan(), "scan fires when charged")
	_check(guard_tag.is_revealed(), "scan reveals a nearby guard")
	_check(guard_tag.title == "MEDIUM ARMOR", "guard shows its armor tier")
	_check(not agent.scanner.try_scan(), "scan can't fire again during cooldown")
	level.free()

	level = await _tower_with_agent_at(Vector2(240, 160), 2)
	agent = level.get_node("Agent")
	guard_tag = level.get_node("Guard/Scannable")
	agent.scanner.try_scan()
	_check(not guard_tag.is_revealed(), "walkway blocks the scan")
	level.free()

	_game_state.unlocked["badge"] = ["wide_scan_1", "deep_scan", "wall_sight"]
	level = await _tower_with_agent_at(Vector2(240, 160), 2)
	agent = level.get_node("Agent")
	guard_tag = level.get_node("Guard/Scannable")
	agent.scanner.try_scan()
	_check(guard_tag.is_revealed(), "Wall Sight upgrade scans through the walkway")
	level.free()
	_game_state.reset()


func _test_ladder() -> void:
	print("Ladder (no jumping)")
	_check(not InputMap.has_action("jump"), "there is no jump action")
	var level: Node = await _tower_with_agent_at(Vector2(135, 228), 10)
	var agent: AgentSide = level.get_node("Agent")
	var walkway_feet: float = level.get_node("Ladder").top_y()
	Input.action_press("move_up")
	for i in 120:
		await get_tree().physics_frame
	Input.action_release("move_up")
	for i in 10:
		await get_tree().physics_frame
	_check(not agent.climbing and absf(agent.global_position.y + 11.0 - walkway_feet) < 1.0,
		"W climbs the ladder up onto the walkway")
	_check(agent.is_on_floor(), "the Agent stands on the walkway at the top")
	Input.action_press("move_down")
	for i in 120:
		await get_tree().physics_frame
	Input.action_release("move_down")
	_check(absf(agent.global_position.y - 229.0) < 1.0, "S climbs back down to the floor")
	level.free()

	level = await _tower_with_agent_at(Vector2(60, 228), 10)
	agent = level.get_node("Agent")
	Input.action_press("move_up")
	for i in 30:
		await get_tree().physics_frame
	Input.action_release("move_up")
	_check(not agent.climbing and agent.global_position.y > 220.0, "W does nothing away from a ladder")
	level.free()


func _test_hub() -> void:
	print("Hub (top-down)")
	var level: Node = load(HUB).instantiate()
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	for i in 30:
		await get_tree().physics_frame
	var guard: Guard = level.get_node("Guard")
	_check(guard.global_position.x > 300.0, "top-down guard walks its route")
	_check(level.get_node("TowerDoor").target_scene == TOWER, "tower door leads to the mission")
	_check(level.get_node("Agent") is AgentTopDown, "hub uses the top-down Agent")
	level.free()
