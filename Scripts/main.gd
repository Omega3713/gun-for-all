extends Node

# Scene preloads
var levelGenScene = preload("res://Scenes/level_generator.tscn")
var prePlayer = preload("res://Scenes/main_character.tscn")
var preWalker = preload("res://Scenes/enemy_walker.tscn")
var preSlime = preload("res://Scenes/enemy_slime.tscn")
var preMenu = preload("res://Scenes/menu_window.tscn")
var preResultsWindow = preload("res://Scenes/results_window.tscn")
var preGameOver = preload("res://Scenes/game_over_window.tscn")

const RoomType = preload("res://Scripts/room_types.gd").RoomType

@onready var _MainWindow: Window = get_window()
@export var player_size: Vector2i = Vector2i(1, 1)

var level_gen: Node = null
var entity_layer: Node = null
var room_size: Vector2
var screen_size: Vector2i = Vector2i.ZERO
var should_start_game := false

func _ready() -> void:
	Globals.set_main_window(_MainWindow)
	
	get_window().title = "Gun for All (v" + Globals.GAME_VERSION + ")"
	
	screen_size = _MainWindow.size

	# Setup Main Window settings
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	_MainWindow.borderless = true
	_MainWindow.unresizable = true
	_MainWindow.gui_embed_subwindows = false
	_MainWindow.transparent = true
	_MainWindow.transparent_bg = false
	_MainWindow.min_size = player_size
	_MainWindow.size = _MainWindow.min_size

	# Open the Main Menu
	var menu = preMenu.instantiate()
	add_child(menu)
	menu.position = (screen_size - menu.size) * 0.5
	menu.world_2d = _MainWindow.world_2d
	menu.transparent = true
	menu.unresizable = true

	menu.menu_action_selected.connect(_on_menu_action_selected)

	await menu.tree_exited

	if should_start_game:
		start_game()
	else:
		print("Player chose Quit. Exiting...")
		await get_tree().create_timer(0.1).timeout
		get_tree().quit()

func _on_menu_action_selected(start_game: bool) -> void:
	should_start_game = start_game

func start_game() -> void:
	Globals.reset_level_stats()

	# Spawn Level
	level_gen = levelGenScene.instantiate()
	add_child(level_gen)

	level_gen.generate_level()
	level_gen.connect_navpoints()

	var start_pos: Vector2i = level_gen.path[0]
	var end_pos: Vector2i = level_gen.path[level_gen.path.size() - 1]
	room_size = level_gen.room_size

	entity_layer = level_gen.get_node("Entity")

	# Spawn Player
	var player = prePlayer.instantiate()
	add_child(player)
	player.reparent(entity_layer)
	player.global_position = (Vector2(start_pos) + Vector2(0.5, 0.5)) * room_size

	Globals.player_window_closed.connect(func():
		print("Player window closed.")
		if get_tree():
			if get_tree().paused:
				print("Unpausing before quit...")
				get_tree().paused = false
				await get_tree().process_frame  # let one frame pass
			get_tree().quit()
	)


	# Spawn Enemies
	spawn_slimes(start_pos, end_pos)
	spawn_walker(end_pos)

func _process(delta: float) -> void:
	Globals.update_timer(delta)

# ---------------------------------------------------
# SPAWN FUNCTIONS

func spawn_slimes(start_pos: Vector2i, end_pos: Vector2i) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var slime_count = 6 + (Globals.stage_number * 2)
	var possible_positions: Array[Vector2i] = []

	for y in range(level_gen.grid_height):
		for x in range(level_gen.grid_width):
			var pos = Vector2i(x, y)
			if level_gen.grid[y][x] != null and level_gen.grid[y][x] != RoomType.FILLER:
				if pos != start_pos and pos != end_pos:
					possible_positions.append(pos)

	possible_positions.shuffle()

	while slime_count > 0 and not possible_positions.is_empty():
		var random_pos = possible_positions.pop_back()

		var slime = preSlime.instantiate()
		add_child(slime)
		slime.reparent(entity_layer)
		slime.global_position = (Vector2(random_pos) + Vector2(0.5, 0.5)) * room_size
		
		slime.slime_defeated.connect(_on_slime_defeated)

		slime_count -= 1
		
func _on_slime_defeated() -> void:
	Globals.slimes_defeated += 1
	print("A slime was defeated! Total:", Globals.slimes_defeated)

func spawn_walker(end_pos: Vector2i) -> void:
	var walker = preWalker.instantiate()
	add_child(walker)
	walker.reparent(entity_layer)
	walker.global_position = (Vector2(end_pos) + Vector2(0.5, 0.5)) * room_size

	# Connect boss defeat
	walker.tree_exited.connect(_on_boss_defeated)

# ---------------------------------------------------
# RESULTS + NEXT STAGE

func _on_boss_defeated() -> void:
	Globals.level_cleared()

	var results = preResultsWindow.instantiate()
	add_child(results)

	var window_size = results.size
	results.position = (screen_size - window_size) * 0.5
	
	if get_tree():
		await get_tree().create_timer(0.1).timeout
		get_tree().paused = true

	results.continue_pressed.connect(_on_continue_after_results)

func _on_continue_after_results() -> void:
	print("Player continuing... Cleaning up...")
	Globals.stage_number += 1

	if get_tree():
		get_tree().paused = false

	if level_gen:
		level_gen.queue_free()
	
	if get_tree():
		await get_tree().create_timer(0.1).timeout

	start_game()

# ---------------------------------------------------
# GAME OVER HANDLING

func game_over() -> void:
	get_tree().paused = true

	var game_over_screen = preGameOver.instantiate()
	add_child(game_over_screen)
	game_over_screen.position = (screen_size - game_over_screen.size) * 0.5

	game_over_screen.restart_requested.connect(func():
		print("Restart requested from Game Over screen")
		Globals.reset_game_state()
		get_tree().paused = false
		start_game()
	)
