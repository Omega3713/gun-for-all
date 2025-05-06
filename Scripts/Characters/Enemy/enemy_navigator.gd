extends Node
class_name EnemyNavigator

@export var enemy_body: CharacterBody2D
@export var move_speed: float = 100.0

var current_navpoint: NavigationPoint = null
var target_navpoint: NavigationPoint = null
var move_type: String = ""

var reached_target_timer: float = 0.0
var move_timeout: float = 0.0

func initialize():
	if not enemy_body:
		push_error("Enemy body not assigned!")
		return
	
	current_navpoint = find_closest_navpoint()
	pick_next_target()

func _physics_process(delta):
	if not current_navpoint or not target_navpoint:
		return
	
	# Physics/movement is now handled fully in EnemyMoveState, not here
	pass
	
func update_navigation(delta):
	if move_timeout > 0.0:
		move_timeout -= delta
		if move_timeout <= 0.0:
			#print("Navigation timeout!")
			on_navigation_timeout()


func pick_next_target():
	if not current_navpoint:
		return

	if current_navpoint.neighbors.is_empty():
		target_navpoint = null
		move_type = ""
		return
	
	var choice = current_navpoint.neighbors.pick_random()
	target_navpoint = choice.target
	move_type = choice.type

	# Reset timers for movement toward the new target
	reached_target_timer = 0.0
	move_timeout = randf_range(1.5, 3.5)  # How long to try before giving up

	#print("Picked new nav target: ", current_navpoint, " -> ", target_navpoint, " (move type: ", move_type, ")")

func on_reached_target():
	#print("aaaaaaaaaaa")
	# Successfully reached the destination
	current_navpoint = target_navpoint
	reached_target_timer = randf_range(2.0, 5.0)  # Wait before picking new
	move_timeout = 0.0
	pick_next_target()

func on_navigation_timeout():
	# Find new closest navpoint
	current_navpoint = find_closest_navpoint()
	target_navpoint = null
	move_type = ""

	# Reset timers
	move_timeout = 0.0
	reached_target_timer = 0.0

	#print("Navigation timeout: Resetting navpoint to ", current_navpoint)

	# After recovery: either pick a new target or idle
	if current_navpoint and not current_navpoint.neighbors.is_empty():
		pick_next_target()
	else:
		if enemy_body:
			enemy_body.change_state("EnemyIdleState")

func find_closest_navpoint() -> NavigationPoint:
	var closest = null
	var min_dist = INF

	for nav in get_tree().get_nodes_in_group("NavigationPoints"):
		var dist = enemy_body.global_position.distance_to(nav.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = nav

	return closest
