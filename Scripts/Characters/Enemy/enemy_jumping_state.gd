extends EnemyState
class_name EnemyJumpingState

var has_jumped: bool = false
var left_ground: bool = false

func enter_state(enemy_node):
	super(enemy_node)
	enemy.enemy_sprite.play("jumping")
	has_jumped = false
	left_ground = false

func physics_update(delta):
	if not enemy.navigator or not enemy.navigator.target_navpoint:
		return

	if enemy.velocity.y < 0:
		enemy.enemy_sprite.frame = 0  # Going up → first frame
	elif enemy.velocity.y > 0:
		enemy.enemy_sprite.frame = 1  # Falling down → second frame
	
	enemy.navigator.update_navigation(delta)  # Still handle timeout

	# Handle waiting after reaching target
	if enemy.navigator.reached_target_timer > 0.0:
		enemy.navigator.reached_target_timer -= delta
		return

	if enemy.navigator.move_type == "jump":
		if not has_jumped and enemy.is_on_floor():
			# Start jump
			enemy.velocity.y = enemy.JUMP_VELOCITY
			has_jumped = true
			#print("Jump started!")

		elif has_jumped:
			# After jumping, wait until we've left ground
			if not enemy.is_on_floor() and not left_ground:
				left_ground = true
				#print("Left the ground!")

			# After we left the ground, landing back triggers target complete
			elif left_ground and enemy.is_on_floor():
				#print("Landed after jump!")
				enemy.navigator.on_reached_target()
				enemy.change_state("EnemyIdleState")
	else:
		# Non-jump horizontal move (if needed)
		var target_dir = (enemy.navigator.target_navpoint.global_position - enemy.global_position).normalized()
		enemy.velocity.x = target_dir.x * enemy.navigator.move_speed

		var distance = enemy.global_position.distance_to(enemy.navigator.target_navpoint.global_position)
		if distance < 5:
			enemy.velocity = Vector2.ZERO
			enemy.navigator.on_reached_target()
			enemy.change_state("EnemyIdleState")

	enemy.move_and_slide()
