extends CharacterBody2D
class_name EnemyWalkerMain

signal boss_defeated  # Signal when boss dies

# Scene Preloads
var preWindow = preload("res://Scenes/window.tscn")
var preBullet = preload("res://Scenes/bullet.tscn")
var preResultsWindow = preload("res://Scenes/results_window.tscn")

# Player / Enemy variables
const BASE_MAX_HEALTH: int = 100
const BASE_FIRE_COOLDOWN: float = 1.0
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var shoot_range: float = 400.0
var fire_timer: float = 0.0
var fire_cooldown: float = BASE_FIRE_COOLDOWN
var health: int

# Movement
var move_direction := 1

# Window
var _EnemyWindow: Window
var _MainWindow: Window
var enemy_window_id = -1

# Components
@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite
@onready var gun_sprite: Sprite2D = $EnemyGun
@onready var muzzle: Marker2D = $EnemyGun/MuzzleMarker
@onready var player: Node2D = null

# State Machine
var current_state: EnemyState

# Navigation
@onready var navigator = $EnemyNavigator
var current_navpoint = null

func _ready() -> void:
	_MainWindow = Globals.get_main_window()
	_EnemyWindow = preWindow.instantiate()

	if _MainWindow == null:
		push_error("ERROR: Failed to find _MainWindow")
		return

	add_child(_EnemyWindow)
	_EnemyWindow.set_parent(self)

	await get_tree().process_frame

	enemy_window_id = _EnemyWindow.get_window_id()
	_EnemyWindow.world_2d = _MainWindow.world_2d
	_EnemyWindow.windowType = 0
	_EnemyWindow.unresizable = true

	if enemy_window_id != -1:
		DisplayServer.window_set_transient(enemy_window_id, -1)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, enemy_window_id)

	# Prevent closing with X button
	_EnemyWindow.close_requested.connect(func():
		print("Enemy window X pressed, ignoring.")
	)

	player = get_node_or_null("/root/Main/LevelGenerator/Entity/Player")

	navigator.enemy_body = self
	navigator.initialize()

	# Scale difficulty based on stage
	var stage = Globals.stage_number
	var scaling = max(0, stage - 2)
	health = BASE_MAX_HEALTH + scaling * 30  # +30 HP per stage after 5
	fire_cooldown = BASE_FIRE_COOLDOWN * (1.0 - min(0.5, scaling * 0.05))  # up to 50% faster shooting

	print("Boss Stage ", stage, ": HP=", health, ", Fire Cooldown=", fire_cooldown)

	change_state("EnemyIdleState")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	update_facing_direction()

	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	fire_timer -= delta

	if player and player.is_inside_tree():
		var distance = global_position.distance_to(player.global_position)
		if distance <= shoot_range and fire_timer <= 0.0:
			shoot()
			fire_timer = fire_cooldown

	if current_state:
		current_state.handle_input(delta)

func change_state(new_state_name: String) -> void:
	if current_state:
		current_state.exit_state()
	current_state = get_node_or_null(new_state_name)
	if current_state:
		current_state.enter_state(self)

func shoot() -> void:
	if not player:
		return

	var bullet = preBullet.instantiate()
	bullet.shooter = self
	bullet.global_position = muzzle.global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(bullet)

func update_facing_direction() -> void:
	if player:
		enemy_sprite.flip_h = move_direction < 0
		gun_sprite.look_at(player.global_position)
		gun_sprite.rotation += deg_to_rad(0)
		gun_sprite.set_flip_v(wrapf(gun_sprite.rotation_degrees, -90, -90 + 360) > -90 + 180)

func flash():
	modulate = Color(1, 0.5, 0.5)  # Light red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Normal again

func take_damage(amount: int) -> void:
	health -= amount
	print("Boss Health: ", health)
	flash()

	if health <= 0:
		die()

func die() -> void:
	print("Boss defeated!")
	boss_defeated.emit()

	queue_free()
