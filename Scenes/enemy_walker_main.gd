extends CharacterBody2D

#Scene Preloads
var preWindow = preload("res://Scenes/window.tscn")
var preBullet = preload("res://Scenes/bullet.tscn")

#Player Variables
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var move_direction := 1
@export var max_health: int = 100
var health: int = max_health

#Gun Variables
@export var fire_rate: float = 0.2  # Time between shots
var can_shoot: bool = true
@onready var muzzle = $EnemyGun/MuzzleMarker  # Get the Marker2D

#Window variables
var _EnemyWindow: Window
var _MainWindow: Window
var enemy_window_id = -1

#Other variables
var current_state
@onready var enemy_sprite: Sprite2D = $EnemySprite
@onready var gun_sprite: Sprite2D = $EnemyGun
@onready var player: Node2D

# Used by JumpingState
func should_jump() -> bool:
	var ground_ahead = is_ground_ahead()
	return not is_on_floor() or not ground_ahead

func is_ground_ahead() -> bool:
	var raycast = RayCast2D.new()
	raycast.position = Vector2(20 * move_direction, 0)  # Offset in front
	raycast.target_position = Vector2(20 * move_direction, 40)  # Downward check
	add_child(raycast)
	raycast.enabled = true
	raycast.force_raycast_update()
	var hit = raycast.is_colliding()
	raycast.queue_free()
	return hit

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.handle_input(delta)


func _ready() -> void:
	_MainWindow = Globals.get_main_window()
	_EnemyWindow = preWindow.instantiate()
	
	var maybe_player = get_node_or_null("/root/Main/Player")
	if maybe_player:
		player = maybe_player
	
	if _MainWindow == null:
		print("ERROR: Failed to instantiate _MainWindow")
		return
	
	# Add it to the scene before modifying its properties
	add_child(_EnemyWindow)
	_EnemyWindow.set_parent(self)
	
	# Wait for the node to be added before modifying world_2d
	await get_tree().process_frame
	
	enemy_window_id = _EnemyWindow.get_window_id()
	
	#window setup
	#sharing the same world as subwindow
	_EnemyWindow.world_2d = _MainWindow.world_2d
	
	# Pass the main window reference to the subwindow
	_EnemyWindow.windowType = 0
	
	# Close main window if this is closed
	#_PlayerWindow.close_requested.connect(Globals.on_subwindow_closed)
	
	# Keep player window in focus
	_EnemyWindow.unresizable = true		# Prevent resizing the window
	if enemy_window_id != -1:
		DisplayServer.window_set_transient(enemy_window_id, -1)  # Remove transient status
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, enemy_window_id)
	
	change_state("EnemyIdleState")
	
func change_state(new_state_name: String):
	if current_state:
		current_state.exit_state()
	current_state = get_node(new_state_name)
	if current_state:
		current_state.enter_state(self)
		
func shoot():
	var bullet = preBullet.instantiate()  # Create bullet instance
	bullet.shooter = self
	bullet.global_position = muzzle.global_position  # Set start position
	bullet.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(bullet)  # Add bullet to scene
	
func update_facing_direction():
	if player:
		# Flip body sprite based on movement direction
		enemy_sprite.flip_h = move_direction < 0

		# Let gun rotate freely toward player
		gun_sprite.look_at(player.global_position)

		# Apply rotation fix if the sprite is facing left/up by default
		# Adjust this based on how your sprite is drawn
		gun_sprite.rotation += deg_to_rad(0)  # Try 90, 180, or 0 to fix orientation
		gun_sprite.set_flip_v(wrapf(gun_sprite.rotation_degrees, -90, -90 + 360) > -90 + 180)
	
func take_damage(amount: int):
	health -= amount
	print("Player Health: ", health)
	
	if health <= 0:
		die()

func die():
	print("Player has died")
	queue_free()
