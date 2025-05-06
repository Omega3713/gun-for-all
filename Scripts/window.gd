extends Window

var pbg_scene = preload("res://Scenes/parallax_background.tscn")

@onready var level: Node = $"/root/Main/LevelGenerator/Background"
@onready var window: Window = $"."
@onready var _Camera: Camera2D = $Camera2D

var parent: Node2D = null

var last_position: Vector2i = Vector2i.ZERO
var velocity: Vector2i = Vector2i.ZERO

var bg: Node
var midbg: Node
var ftbg: Node

var main_window: Window = Globals.get_main_window()
var windowType: int = 0  # 0 = follow parent, 1 = stationary

func _ready() -> void:
	main_window = Globals.get_main_window()
	
	transient = true  # Make this window considered as child of main
	
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	
	_initialise_background()


func _initialise_background():
	var instance = pbg_scene.instantiate()
	instance.custom_viewport = window

	bg = instance.find_child("Background")
	midbg = instance.find_child("MidFogBg")
	ftbg = instance.find_child("FrontFogBg")

	# Set backgrounds at (0,0)
	if bg: bg.global_position = Vector2.ZERO
	if midbg: midbg.global_position = Vector2.ZERO
	if ftbg: ftbg.global_position = Vector2.ZERO

	level.add_child(instance)

	# If this window is a stationary Results window, overlay a dim transparent layer
	if windowType == 1:
		var dim_layer = ColorRect.new()
		dim_layer.color = Color(0, 0, 0, 0.5)  # Black, 50% transparent
		dim_layer.size = main_window.size
		dim_layer.anchor_right = 1.0
		dim_layer.anchor_bottom = 1.0
		dim_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE  # So it doesn't block input
		level.add_child(dim_layer)


func _update_background() -> void:
	if bg: bg.global_position = main_window.position
	if midbg: midbg.global_position = main_window.position
	if ftbg: ftbg.global_position = main_window.position

func _process(delta: float) -> void:
	_update_background()

	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()

	if windowType == 0:
		follow_parent()

func get_camera_pos_from_window() -> Vector2i:
	return position + velocity

func follow_parent() -> void:
	if parent:
		var target_position = parent.global_position - Vector2(size.x, size.y) / 2
		position = target_position

func set_parent(p: Node2D) -> void:
	parent = p
