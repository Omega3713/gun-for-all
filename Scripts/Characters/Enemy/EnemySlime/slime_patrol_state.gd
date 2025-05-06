extends EnemyState
class_name SlimePatrolState

func enter_state(enemy_node):
	super(enemy_node)

func exit_state():
	pass

func handle_input(delta):
	if not enemy.navigator or not enemy.navigator.target_navpoint:
		enemy.change_state("SlimeIdleState")
		return

	# Chase player if near
	if enemy.player and enemy.global_position.distance_to(enemy.player.global_position) <= enemy.aggro_distance:
		enemy.change_state("SlimeChaseState")
		return

func physics_update(delta):
	if not enemy.navigator or not enemy.navigator.target_navpoint:
		return

	var target_dir = (enemy.navigator.target_navpoint.global_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(enemy.navigator.target_navpoint.global_position)
	
	enemy.velocity.x = target_dir.x * enemy.move_speed

	# Gravity
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()

	# If reached navpoint
	if distance < 5:
		enemy.navigator.on_reached_target()
		enemy.change_state("SlimeIdleState")
