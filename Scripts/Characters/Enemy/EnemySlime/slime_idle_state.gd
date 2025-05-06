extends EnemyState
class_name SlimeIdleState

var wait_timer: float = 0.0
var timer := 0.0

func enter_state(enemy_node):
	super(enemy_node)
	enemy.velocity.x = 0
	timer = 0.0
	wait_timer = randf_range(0.5, 1.5)
	print("Slime entered IdleState, waiting for ", wait_timer, " seconds.")

func exit_state():
	pass

func handle_input(delta):
	timer += delta
	
	var slime = enemy as SlimeMain
	if slime.player and slime.global_position.distance_to(slime.player.global_position) <= slime.aggro_distance:
		slime.change_state("SlimeChaseState")
		return

	# After waiting, start patrolling
	if timer >= wait_timer:
		if slime.navigator:
			slime.navigator.pick_next_target()

		if slime.navigator and slime.navigator.target_navpoint:
			slime.change_state("SlimePatrolState")


func physics_update(delta):
	# If falls (off edge), allow gravity
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta
	enemy.move_and_slide()
