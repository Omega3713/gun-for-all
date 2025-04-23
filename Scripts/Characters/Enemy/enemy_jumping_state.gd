extends EnemyState

var jumped := false

func enter_state(enemy_node):
	super.enter_state(enemy_node)
	jumped = false

func physics_update(delta):
	enemy.update_facing_direction()

	if not jumped:
		enemy.velocity.y = enemy.JUMP_VELOCITY
		jumped = true

	enemy.velocity.y += enemy.get_gravity().y * delta
	enemy.move_and_slide()
	#print("Velocity: ",enemy.velocity.y)
	#print("On floor: ",enemy.is_on_floor())
	#print("Ray check: ",enemy.ground_check.is_colliding())
	
	if enemy.is_on_floor():
		print("it works now for some reason?")
		enemy.change_state("EnemyIdleState")
