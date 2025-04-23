extends Node

#Scene preloads
var prePlayer = preload("res://Scenes/main_character.tscn")
var preEnemy = preload("res://Scenes/enemy_walker.tscn")


@onready var entity_layer: Node = $Level/Entity
@onready var _MainWindow: Window = get_window()
#@onready var _SubWindow: Window = $Window
@export var player_size: Vector2i = Vector2i(1, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.set_main_window(_MainWindow)
	var player = prePlayer.instantiate()
	var enemy = preEnemy.instantiate()
	add_child(player)
	add_child(enemy)
	player.reparent(entity_layer)
	enemy.reparent(entity_layer)
	player.global_position = Vector2(150,450)
	enemy.global_position = Vector2(300, 450)
	
# declare the variables...
		# Enable per-pixel transparency, required for transparent windows but has a performance cost
		# Can also break on some systems
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
		# Set the window settings - most of them can be set in the project settings
	_MainWindow.borderless = true		# Hide the edges of the window
	_MainWindow.unresizable = true		# Prevent resizing the window
	#_MainWindow.always_on_top = true	# Force the window always be on top of the screen
	_MainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	_MainWindow.transparent = true		# Allow the window to be transparent
		# Settings that cannot be set in project settings
	_MainWindow.transparent_bg = false	# Make the window's background transparent
		# set the subwindow's world...
		# The window's size may need to be smaller than the default minimum size
	# so we have to change the minimum size BEFORE setting the window's size
	_MainWindow.min_size = player_size
	_MainWindow.size = _MainWindow.min_size
	
	Globals.player_window_closed.connect(func():
		print("Player window closed. Exiting from main.")
		await get_tree().process_frame  # Let subwindow cleanup settle
		await get_tree().create_timer(0.1).timeout  # Delay 1/10 second
		get_tree().quit()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_subwindow_closed() -> void:
	# Close the main window when the subwindow is closed
	get_tree().quit()
