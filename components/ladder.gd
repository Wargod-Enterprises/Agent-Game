@tool
class_name Ladder
extends Area2D
## A ladder (side view). Place this node where the ladder meets the ground;
## it reaches `height` pixels up. The Agent climbs with W/S, or E to grab
## and let go. Climbing is silent.

@export var height := 64.0:
	set(value):
		height = value
		_apply()

## Extra reach above the top so the Agent can grab it from the floor above.
const TOP_REACH := 12.0
const WIDTH := 12.0

var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_apply()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


## World y of the ladder's top and bottom (where the Agent's feet stop).
func top_y() -> float:
	return global_position.y - height


func bottom_y() -> float:
	return global_position.y


func _apply() -> void:
	if _shape:
		(_shape.shape as RectangleShape2D).size = Vector2(WIDTH, height + TOP_REACH)
		_shape.position = Vector2(0, -(height + TOP_REACH) / 2.0)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body is AgentSide:
		body.nearby_ladder = self


func _on_body_exited(body: Node) -> void:
	if body is AgentSide and body.nearby_ladder == self:
		body.nearby_ladder = null


func _draw() -> void:
	var c := Color(0.55, 0.5, 0.42)
	draw_line(Vector2(-5, 0), Vector2(-5, -height), c, 1.0)
	draw_line(Vector2(5, 0), Vector2(5, -height), c, 1.0)
	var y := -4.0
	while y > -height:
		draw_line(Vector2(-5, y), Vector2(5, y), c, 1.0)
		y -= 8.0
