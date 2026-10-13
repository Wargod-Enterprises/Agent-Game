class_name AgentSide
extends Agent
## The Agent in side view: walk, fall, climb ladders. No free jump; getting
## between floors goes through ladders (and later vents, stairs, elevators).

const SPEED := 90.0
const SNEAK_SPEED := 45.0
const CLIMB_SPEED := 50.0
const GRAVITY := 600.0

## Set by a Ladder while the Agent overlaps it.
var nearby_ladder: Ladder = null
var climbing := false


func _move(delta: float) -> bool:
	if climbing:
		_climb(delta)
		return false
	if _wants_to_climb():
		climbing = true
		velocity = Vector2.ZERO
		global_position.x = nearby_ladder.global_position.x
		return false

	var was_airborne := not is_on_floor()
	if was_airborne:
		velocity.y += GRAVITY * delta

	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * (SNEAK_SPEED if sneaking else SPEED)
	if dir != 0.0:
		facing = Vector2(signf(dir), 0)

	move_and_slide()
	if was_airborne and is_on_floor() and not sneaking:
		make_noise(run_noise_radius * 0.8)
	return dir != 0.0 and is_on_floor()


func _feet_y() -> float:
	return global_position.y + body_size.y / 2.0


func _wants_to_climb() -> bool:
	if nearby_ladder == null or not is_on_floor():
		return false
	var feet := _feet_y()
	var can_go_up := feet > nearby_ladder.top_y() + 1.0
	var can_go_down := feet < nearby_ladder.bottom_y() - 1.0
	if Input.is_action_just_pressed("interact"):
		return can_go_up or can_go_down
	return (Input.is_action_pressed("move_up") and can_go_up) \
		or (Input.is_action_pressed("move_down") and can_go_down)


## Climbing moves the Agent directly, passing through the floor it leads to.
func _climb(delta: float) -> void:
	if nearby_ladder == null or Input.is_action_just_pressed("interact"):
		climbing = false  # let go and drop
		return
	var dir := Input.get_axis("move_up", "move_down")
	global_position.y += dir * CLIMB_SPEED * delta
	var half := body_size.y / 2.0
	if _feet_y() <= nearby_ladder.top_y():
		global_position.y = nearby_ladder.top_y() - half
		climbing = false
	elif _feet_y() >= nearby_ladder.bottom_y():
		global_position.y = nearby_ladder.bottom_y() - half
		climbing = false
