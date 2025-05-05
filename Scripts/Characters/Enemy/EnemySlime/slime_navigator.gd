extends Node
class_name SlimeNavigator

@export var enemy_body: CharacterBody2D
@export var move_speed: float = 100.0
@export var max_patrol_distance: float = 250.0  # Only choose patrol points within this distance

var current_navpoint: Node2D = null
var target_navpoint: Node2D = null

func initialize() -> void:
	if not enemy_body:
		push_error("SlimeNavigator: enemy_body not assigned!")
		return

	current_navpoint = find_closest_navpoint()
	pick_next_target()

func _physics_process(delta: float) -> void:
	if not enemy_body or not target_navpoint:
		return

	move_towards(target_navpoint.global_position, move_speed)

func move_towards(target_pos: Vector2, speed: float) -> void:
	var direction = (target_pos - enemy_body.global_position).normalized()
	enemy_body.velocity.x = direction.x * speed
	enemy_body.move_and_slide()

func pick_next_target() -> void:
	var candidates = []

	for nav in get_tree().get_nodes_in_group("NavigationPoints"):
		if nav == current_navpoint:
			continue

		var dist = current_navpoint.global_position.distance_to(nav.global_position)
		if dist <= max_patrol_distance:
			candidates.append(nav)

	if candidates.is_empty():
		# fallback to random ANY navpoint if none close enough
		candidates = get_tree().get_nodes_in_group("NavigationPoints")

	# Pick random among nearby candidates
	target_navpoint = candidates.pick_random()
	print(current_navpoint," ",target_navpoint)

func find_closest_navpoint() -> Node2D:
	var closest = null
	var min_dist = INF

	for nav in get_tree().get_nodes_in_group("NavigationPoints"):
		var dist = enemy_body.global_position.distance_to(nav.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = nav

	return closest

func on_reached_target() -> void:
	current_navpoint = target_navpoint
	target_navpoint = null
