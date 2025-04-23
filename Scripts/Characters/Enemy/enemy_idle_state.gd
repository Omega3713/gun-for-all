extends EnemyState

@export var shoot_range: float = 300.0
var shoot_cooldown := 0.0
var distance := 0.0

func enter_state(enemy_node):
	super.enter_state(enemy_node)
	shoot_cooldown = 0.0

func physics_update(delta):
	shoot_cooldown -= delta

	# Gravity
	var velocity = enemy.velocity
	if not enemy.is_on_floor():
		velocity.y += enemy.get_gravity().y * delta
	else:
		velocity.y = 0
	enemy.velocity = velocity
	enemy.move_and_slide()

	# State logic
	enemy.update_facing_direction()
	if is_instance_valid(enemy.player):
		distance = enemy.global_position.distance_to(enemy.player.global_position)
		#print("this is distance:",distance)
	
	#print("distance to player:", distance)

	if enemy.player and distance < shoot_range and shoot_cooldown <= 0:
		#print("PLAYER IN RANGE, SHOOTING")
		enemy.shoot()
		shoot_cooldown = 1.0

	if enemy.should_jump():
		#print("JUMPING")
		enemy.change_state("EnemyJumpingState")
	elif distance > 500:
		#print("PLAYER TOO FAR, MOVING")
		enemy.change_state("EnemyMovingState")
