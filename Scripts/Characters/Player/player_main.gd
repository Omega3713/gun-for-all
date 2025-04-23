extends CharacterBody2D

#Scene Preloads
var preWindow = preload("res://Scenes/window.tscn")
var preBullet = preload("res://Scenes/bullet.tscn")

#Player Variables
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var last_facing_direction = 1
@export var max_health: int = 100
var health: int = max_health

#Gun Variables
@export var fire_rate: float = 0.2  # Time between shots
var can_shoot: bool = true
@onready var muzzle = $PlayerGun/MuzzleMarker  # Get the Marker2D

#Window variables
var _PlayerWindow: Window
var _MainWindow: Window
var player_window_id = -1

#UI variables
var health_label = null

#State variables
var current_state
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var gun_sprite: Sprite2D = $PlayerGun

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		last_facing_direction = sign(direction)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if current_state:
		current_state.handle_input(delta)
		
	move_and_slide()
	
	if direction >= 1:
		player_sprite.flip_h = false
		gun_sprite.flip_h = false
	elif direction <= -1:
		player_sprite.flip_h = true
		#gun_sprite.flip_h = true
		
	gun_sprite.look_at(get_global_mouse_position())
	gun_sprite.set_flip_v(wrapf(gun_sprite.rotation_degrees, -90, -90 + 360) > -90 + 180)
	
func _process(delta):
	if Input.is_action_just_pressed("fire") and can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout  # Delay next shot
		can_shoot = true
		


func _ready() -> void:
	_MainWindow = Globals.get_main_window()
	_PlayerWindow = preWindow.instantiate()
	
	if _MainWindow == null:
		print("ERROR: Failed to instantiate _MainWindow")
		return
	
	# Add it to the scene before modifying its properties
	add_child(_PlayerWindow)
	_PlayerWindow.set_parent(self)
	
	# Wait for the node to be added before modifying world_2d
	await get_tree().process_frame
	
	player_window_id = _PlayerWindow.get_window_id()
	
	#window setup
	#sharing the same world as subwindow
	_PlayerWindow.world_2d = _MainWindow.world_2d
	
	# Pass the main window reference to the subwindow
	_PlayerWindow.windowType = 0
	
	# Close main window if this is closed
	_PlayerWindow.close_requested.connect(_on_close_requested)
	
	# Keep player window in focus
	_PlayerWindow.unresizable = true		# Prevent resizing the window
	if player_window_id != -1:
		DisplayServer.window_set_transient(player_window_id, -1)  # Remove transient status
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true, player_window_id)
	
	for node in _PlayerWindow.get_node("UI").get_children():
		print("UI child: ", node.name," ", "Type: ", node.get_class())

	while not _PlayerWindow.has_node("UI/PlayerHealthLabel"):
		await get_tree().process_frame
	
	print("a")
	health_label = _PlayerWindow.get_node("UI/PlayerHealthLabel")
	print(health_label)
	health_label.visible = true
	print(health_label.text)
	update_health_ui()
	
	change_state("IdleState")
	
func change_state(new_state_name: String):
	if current_state:
		current_state.exit_state()
	current_state = get_node(new_state_name)
	if current_state:
		current_state.enter_state(self)
		
func shoot():
	if player_window_id != -1: 
		DisplayServer.window_move_to_foreground(player_window_id)
	var bullet = preBullet.instantiate()  # Create bullet instance
	bullet.shooter = self
	bullet.global_position = muzzle.global_position  # Set start position
	bullet.direction = (get_global_mouse_position() - muzzle.global_position).normalized()  # Get direction
	get_parent().add_child(bullet)  # Add bullet to scene


	
func take_damage(amount: int):
	health -= amount
	update_health_ui()

	print("Player Health: ", health)

	if health <= 0:
		die()

func die():
	print("Player has died")
	queue_free()
	
func update_health_ui():
	if health_label:
		var percent := int(health * 100 / max_health)
		health_label.text = "HP: %d/%d (%d%%)" % [health, max_health, percent]



	
func _on_close_requested():
	# Prevent shutdown issues
	if player_window_id != -1:
		visible = false
		player_window_id = -1

		# Tell the main scene to quit after one frame
		await get_tree().process_frame
		Globals.emit_signal("player_window_closed")

	
	
