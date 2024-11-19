extends Window

var pbg_scene = preload("res://Scenes/parallax_background.tscn")
@onready var level: Node = $"../Level/Background"
@onready var window: Window = $"."

@onready var _Camera: Camera2D = $Camera2D

var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var bg: Node
var midbg: Node
var ftbg: Node

func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	_initialise_background()
	
	transient = true # Make the window considered as a child of the main window
	close_requested.connect(queue_free) # Actually close the window when clicking the close button
	
func _initialise_background():
	var instance = pbg_scene.instantiate()
	instance.custom_viewport = window
	bg = instance.find_child("Background")
	midbg = instance.find_child("MidFogBg")
	ftbg = instance.find_child("FrontFogBg")
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

func get_camera_pos_from_window()->Vector2i:
	return position + velocity
