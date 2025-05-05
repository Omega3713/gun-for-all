extends EnemyState
class_name EnemyIdleState

var wait_timer: float = 0.0
var timer: float = 0.0

func enter_state(enemy_node):
	super(enemy_node)
	enemy.velocity.x = 0  # Stop completely
	timer = 0.0
	wait_timer = randf_range(0.5, 1.5)  # Randomized idle time
	enemy.enemy_sprite.play("idle")

func exit_state():
	pass

func handle_input(delta):
	timer += delta

	if timer >= wait_timer:
		if enemy.navigator:
			enemy.navigator.pick_next_target()

			# Only move if a valid target was picked
			if enemy.navigator.target_navpoint:
				enemy.change_state("EnemyMovingState")
			else:
				# No target? Remain idle and reset timer
				timer = 0.0
				wait_timer = randf_range(0.5, 1.5)

func physics_update(delta):
	# If enemy falls off something, transition to jump/fall handling
	if not enemy.is_on_floor():
		enemy.change_state("EnemyJumpingState")
