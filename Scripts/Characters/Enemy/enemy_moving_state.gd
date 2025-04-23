extends EnemyState

@export var patrol_speed: float = 100.0
@export var patrol_range: float = 200.0
@export var min_pause_time: float = 0.5
@export var max_pause_time: float = 2.0
@export var random_flip_chance_per_second: float = 0.3

var start_position: Vector2
var has_set_start := false
var direction: int = 1
var is_paused: bool = false
var pause_timer: float = 0.0
var current_pause_duration: float = 0.0

@onready var enemy_sprite: Sprite2D = null
@onready var gun_sprite: Sprite2D = null

func enter_state(enemy_node):
	super.enter_state(enemy_node)
	if not has_set_start:
		start_position = enemy.global_position
		has_set_start = true
	enemy_sprite = enemy.get_node("EnemySprite")
	gun_sprite = enemy.get_node("EnemyGun")
	is_paused = false
	pause_timer = 0.0
	current_pause_duration = 0.0

func physics_update(delta):
	if enemy.player and enemy.global_position.distance_to(enemy.player.global_position) < 500:
		print("PLAYER BACK IN RANGE — MOVING → IDLE")
		enemy.change_state("EnemyIdleState")
		return
	
	if is_paused:
		pause_timer += delta
		if pause_timer >= current_pause_duration:
			is_paused = false
			pause_timer = 0.0
			print("Pause over, continuing patrol")
		else:
			# While paused, apply gravity and stay put
			var velocity = enemy.velocity
			if not enemy.is_on_floor():
				velocity.y += enemy.get_gravity().y * delta
			else:
				velocity.y = 0
			velocity.x = 0
			enemy.velocity = velocity
			enemy.move_and_slide()
			return  # skip the rest
		

	var velocity = enemy.velocity

	# Gravity
	if not enemy.is_on_floor():
		velocity.y += enemy.get_gravity().y * delta
	else:
		velocity.y = 0
		
	if randf() < random_flip_chance_per_second * delta and not is_paused:
		direction *= -1
		start_pause()

	# Check patrol bounds and flip
	var distance_from_start = enemy.global_position.x - start_position.x
	if direction == 1 and distance_from_start >= patrol_range:
		direction = -1
		start_pause()
	elif direction == -1 and distance_from_start <= -patrol_range:
		direction = 1
		start_pause()

	# Patrol movement
	velocity.x = patrol_speed * direction
	enemy.velocity = velocity
	enemy.move_and_slide()
	
	enemy.move_direction = direction
	enemy.update_facing_direction()

	if enemy.should_jump():
		enemy.change_state("EnemyJumpingState")

func start_pause():
	is_paused = true
	current_pause_duration = randf_range(min_pause_time, max_pause_time)
	print("Starting random pause for ", current_pause_duration, "s")
