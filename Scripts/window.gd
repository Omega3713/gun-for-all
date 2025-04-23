extends Window


var pbg_scene = preload("res://Scenes/parallax_background.tscn")
@onready var level: Node = $"/root/Main/Level/Background"
@onready var window: Window = $"."
var main_window: Window = Globals.get_main_window()
@onready var parent: Node2D
@onready var _Camera: Camera2D = $Camera2D

var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var bg: Node
var midbg: Node
var ftbg: Node

var windowType: int

func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	
	main_window = Globals.get_main_window()
	
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	_initialise_background()
	
	transient = true # Make the window considered as a child of the main window
	close_requested.connect(queue_free) # Actually close the window when clicking the close button
	
#func set_main_window(window_ref: Window) -> void:
	#main_window = window_ref
	
func _initialise_background():
	var instance = pbg_scene.instantiate()
	instance.custom_viewport = window
	
	var main_window_size = main_window.size if main_window else window.size
	
	bg = instance.find_child("Background")
	midbg = instance.find_child("MidFogBg")
	ftbg = instance.find_child("FrontFogBg")
	
	# Ensure background layers are positioned at the main window's top-left
	if bg:
		bg.global_position = Vector2.ZERO
	if midbg:
		midbg.global_position = Vector2.ZERO
	if ftbg:
		ftbg.global_position = Vector2.ZERO

	# Scale the backgrounds to match the main window size
	#if bg:
		#Vector2(main_window_size.x / window.size.x, main_window_size.y / window.size.y)
		#bg.scale = Vector2(1,1)
	#if midbg:
		#midbg.scale = Vector2(1920,1080)
	#if ftbg:
		#ftbg.scale = Vector2(1920,1080)
	
	level.add_child(instance)
	
func _update_background() -> void:
	#bg.scale = Vector2(1,1)
	#midbg.scale = Vector2(1920,1080)
	#ftbg.scale = Vector2(1920,1080)
	bg.global_position = Vector2(0,0)
	midbg.global_position = Vector2(0,0)
	ftbg.global_position = Vector2(0,0)

func _process(delta: float) -> void:
	_update_background()
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()
	
	if bg:
		bg.global_position = main_window.position
	if midbg:
		midbg.global_position = main_window.position
	if ftbg:
		ftbg.global_position = main_window.position
		
	#print("bg position", bg.global_position)
	if windowType == 0:
		follow_parent()

func get_camera_pos_from_window()->Vector2i:
	return position + velocity

func follow_parent() -> void:
	if parent:
		var target_position = parent.global_position - Vector2(size.x, size.y) / 2  # Center window on parent
		position = target_position
		
func set_parent(p: Node2D):
	parent = p
