extends EnemyState
class_name EnemyMovingState

func enter_state(enemy_node):
	super(enemy_node)

func physics_update(delta):
	if not enemy.navigator or not enemy.navigator.target_navpoint:
		return
	
	if !enemy.is_on_floor():
		enemy.enemy_sprite.play("jumping")
		if enemy.velocity.y < 0:
			enemy.enemy_sprite.frame = 0  # Going up → first frame
		elif enemy.velocity.y > 0:
			enemy.enemy_sprite.frame = 1  # Falling down → second frame
	
	# Let the navigator handle timeout
	enemy.navigator.update_navigation(delta)

	# If the navigator says we don't have a target anymore, go idle
	if not enemy.navigator.target_navpoint:
		enemy.velocity = Vector2.ZERO
		enemy.change_state("EnemyIdleState")
		return

	# Handle waiting after reaching target
	if enemy.navigator.reached_target_timer > 0.0:
		enemy.velocity.x = 0
		enemy.move_and_slide()
		return

	# Move towards the current target
	var direction = (enemy.navigator.target_navpoint.global_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(enemy.navigator.target_navpoint.global_position)
	
	enemy.velocity.x = direction.x * enemy.navigator.move_speed
	
	if enemy.is_on_floor() and enemy.velocity.x >= 5:
		enemy.enemy_sprite.play("running")
	else:
		enemy.enemy_sprite.play("idle")

	# Jump if needed
	if enemy.navigator.move_type == "jump" and enemy.is_on_floor():
		enemy.change_state("EnemyJumpingState")
		return

	enemy.move_and_slide()

	# Reached navpoint
	if distance < 5:
		enemy.velocity = Vector2.ZERO
		enemy.navigator.on_reached_target()
