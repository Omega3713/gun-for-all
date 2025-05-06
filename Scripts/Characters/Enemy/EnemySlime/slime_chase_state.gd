extends EnemyState
class_name SlimeChaseState

func enter_state(enemy_node):
	super(enemy_node)

func exit_state():
	pass

func handle_input(delta):
	if not enemy.player:
		return
	
	var dist = enemy.global_position.distance_to(enemy.player.global_position)

	if dist > enemy.aggro_distance * 1.5:
		# Player got too far, return to patrolling
		if enemy.navigator and enemy.navigator.target_navpoint:
			enemy.change_state("SlimePatrolState")
		else:
			enemy.change_state("SlimeIdleState")
		return

func physics_update(delta):
	if not enemy.player:
		return

	var target_dir = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.velocity.x = target_dir.x * enemy.move_speed

	# Gravity
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
