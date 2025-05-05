extends Node2D

const RoomType = preload("res://Scripts/room_types.gd").RoomType

# GRID SETTINGS
@export var grid_width := 8
@export var grid_height := 4
@export var room_size := Vector2(240, 270)

@export var filler_rooms: Array[PackedScene]
@export var horizontal_rooms: Array[PackedScene]
@export var lr_bottom_rooms: Array[PackedScene]
@export var lr_top_rooms: Array[PackedScene]
@export var vertical_rooms: Array[PackedScene]
@export var arena_rooms: Array[PackedScene]

@onready var background_node = $Background
@onready var entity_node = $Entity
@onready var foreground_node = $Foreground

var grid: Array = []
var visited: Dictionary = {}
var main_path: Dictionary = {}
var branch_starts: Dictionary = {}
var path: Array[Vector2i] = []

func _ready():
	load_room_templates()
	#generate_level()
	#connect_navpoints()
	
func connect_navpoints():
	var all_navpoints = get_tree().get_nodes_in_group("NavigationPoints")
	auto_connect_navpoints(all_navpoints)
	
func auto_connect_navpoints(navpoints: Array, max_walk_distance: float = 48.0, max_jump_height: float = 100.0) -> void:
	for nav_a in navpoints:
		for nav_b in navpoints:
			if nav_a == nav_b:
				continue

			var offset = nav_b.global_position - nav_a.global_position

			# Flat walk
			if abs(offset.y) < 10.0 and offset.length() <= max_walk_distance:
				if has_line_of_sight(nav_a.global_position, nav_b.global_position):
					nav_a.add_neighbor(nav_b, "walk")

			# Jump up
			elif offset.y < 0 and offset.length() <= max_jump_height:
				if has_line_of_sight(nav_a.global_position, nav_b.global_position):
					nav_a.add_neighbor(nav_b, "jump")

			# Fall down
			elif offset.y > 0 and abs(offset.x) < max_walk_distance:
				if has_line_of_sight(nav_a.global_position, nav_b.global_position):
					nav_a.add_neighbor(nav_b, "fall")
		print(nav_a,"\n")
		for keys in nav_a.neighbors:
			print(keys)
		print("\n")

func has_line_of_sight(from: Vector2, to: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = from
	query.to = to
	query.collision_mask = 1  # Assuming walls are on layer 1

	var result = space_state.intersect_ray(query)
	return result.is_empty()




func generate_level():
	grid.clear()
	visited.clear()
	main_path.clear()
	branch_starts.clear()
	path.clear()

	for y in range(grid_height):
		grid.append([])
		for x in range(grid_width):
			grid[y].append(null)

	# Main path generation
	var current_pos = Vector2i(randi() % grid_width, 0)
	visited[current_pos] = true
	main_path[current_pos] = true
	path.append(current_pos)

	var last_move_down = false

	while true:
		var possible_moves = []

		if current_pos.x > 0 and not visited.has(current_pos + Vector2i(-1, 0)):
			possible_moves.append(Vector2i(-1, 0))
		if current_pos.x < grid_width - 1 and not visited.has(current_pos + Vector2i(1, 0)):
			possible_moves.append(Vector2i(1, 0))
		if current_pos.y < grid_height - 1 and not visited.has(current_pos + Vector2i(0, 1)):
			possible_moves.append(Vector2i(0, 1))

		if possible_moves.is_empty():
			break

		var move = possible_moves.pick_random()
		var next_pos = current_pos + move

		print("m, room type: ", current_pos.x," ",current_pos.y)
		if move == Vector2i(0, 1):
			grid[current_pos.y][current_pos.x] = RoomType.VERTICAL if last_move_down else RoomType.LRB
			last_move_down = true
		else:
			grid[current_pos.y][current_pos.x] = RoomType.LRT if last_move_down else RoomType.HORIZONTAL
			last_move_down = false
		print("m, new room type: ", grid[current_pos.y][current_pos.x])

		current_pos = next_pos
		visited[current_pos] = true
		main_path[current_pos] = true
		path.append(current_pos)

	# Final room
	if grid[current_pos.y][current_pos.x] == null:
		grid[current_pos.y][current_pos.x] = RoomType.ARENA

	# Generate branches
	for start_pos in path:
		if randi() % 100 < 50:
			try_branch_from(start_pos)

	# Fix room types
	#fix_room_types()

	# Fill gaps
	for y in range(grid_height):
		for x in range(grid_width):
			if grid[y][x] == null:
				grid[y][x] = RoomType.FILLER

	# Spawn rooms
	for y in range(grid_height):
		for x in range(grid_width):
			spawn_room(grid[y][x], x, y)

	print_debug_minimap()

func try_branch_from(start_pos: Vector2i):
	var branch_length = randi_range(4, 7)
	var directions = []

	var pos = start_pos
		
	var dir = null
	var prev_dir = null
	var first_step = true
	
	print("branching")
	print("branch start pos: ", start_pos)
	print("branch length: ",branch_length)
	for i in range(branch_length):
		directions.clear()
		
		if is_valid_position(Vector2i(pos.x,pos.y+1)):
			if grid[pos.y+1][pos.x] == null and pos.y < grid_height - 2:
				directions.append(Vector2i(0, 1))
		if is_valid_position(Vector2i(pos.x+1,pos.y)):
			if grid[pos.y][pos.x+1] == null:
				directions.append(Vector2i(1, 0))
		if is_valid_position(Vector2i(pos.x-1,pos.y)):
			if grid[pos.y][pos.x-1] == null:
				directions.append(Vector2i(-1, 0))
		print("directions: ",directions)
		
		if directions.is_empty():
			if !first_step:
				grid[pos.y][pos.x] = RoomType.ARENA
			break
			
		prev_dir = dir
		dir = directions.pick_random()
		var next_pos = pos + dir

		print("next_pos: ", next_pos)
		# Prevent branch from moving downward into the bottom layer
		#if dir == Vector2i(0, 1) and pos.y >= grid_height - 2:
		#	break

		# Check validity
		print("valid? not visited? ", is_valid_position(next_pos), " ",not visited.has(next_pos))
		if is_valid_position(next_pos) and not visited.has(next_pos):
			if first_step:
				branch_starts[next_pos] = true
				first_step = false

			# Mark the room type depending on move
			if dir == Vector2i(0, 1):
				if grid[pos.y][pos.x] == RoomType.HORIZONTAL:
					grid[pos.y][pos.x] = RoomType.LRB
				elif grid[pos.y][pos.x] == RoomType.LRT:
					grid[pos.y][pos.x] = RoomType.ARENA
				elif grid[pos.y][pos.x] == null:
					print(prev_dir)
					print(Vector2i(1,0))
					print(Vector2i(-1,0))
					print((prev_dir != Vector2i(1, 0)))
					print((prev_dir != Vector2i(-1, 0)))
					print((prev_dir != Vector2i(1, 0)) or (prev_dir != Vector2i(-1, 0)))
					if (prev_dir != Vector2i(1, 0)) and (prev_dir != Vector2i(-1, 0)):
						grid[pos.y][pos.x] = RoomType.VERTICAL
					else:
						grid[pos.y][pos.x] = RoomType.ARENA
			elif dir == Vector2i(1,0) or dir == Vector2i(-1,0):
				if grid[pos.y][pos.x] == RoomType.VERTICAL:
					grid[pos.y][pos.x] = RoomType.ARENA
				elif grid[pos.y][pos.x] == null:
					if prev_dir != Vector2i(0, 1):
						grid[pos.y][pos.x] = RoomType.HORIZONTAL
					else:
						grid[pos.y][pos.x] = RoomType.LRT
			print("new room type: ",pos.x, " ",pos.y, " -- ",grid[pos.y][pos.x])

			visited[pos] = true
			pos = next_pos
		else:
			break


func fix_room_types():
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)

			if grid[y][x] == null:
				continue
			if main_path.has(pos):
				continue  # Do not touch main path room types

			# Only allow neighbors that are on the main path or a branch start
			var has_left = false
			if x > 0 and grid[y][x-1] != null:
				var neighbor = Vector2i(x-1, y)
				if main_path.has(neighbor) or branch_starts.has(neighbor):
					has_left = true

			var has_right = false
			if x < grid_width-1 and grid[y][x+1] != null:
				var neighbor = Vector2i(x+1, y)
				if main_path.has(neighbor) or branch_starts.has(neighbor):
					has_right = true

			var has_up = false
			if y > 0 and grid[y-1][x] != null:
				var neighbor = Vector2i(x, y-1)
				if main_path.has(neighbor) or branch_starts.has(neighbor):
					has_up = true

			var has_down = false
			if y < grid_height-1 and grid[y+1][x] != null:
				var neighbor = Vector2i(x, y+1)
				if main_path.has(neighbor) or branch_starts.has(neighbor):
					has_down = true
					
			print("branches: ",branch_starts)
			print("room type: ", grid[y][x])
			print("pos: ",x," ",y)
			print("has left: ", has_left)
			print("has right: ", has_right)
			print("has up: ", has_up)
			print("has down: ", has_down)

			# Set room type based on neighbor structure
			if (has_up and has_down) and (has_left or has_right):
				grid[y][x] = RoomType.ARENA
			elif has_up and has_down:
				grid[y][x] = RoomType.VERTICAL
			elif (has_left or has_right) and has_down:
				grid[y][x] = RoomType.LRB
			elif (has_left or has_right) and has_up:
				grid[y][x] = RoomType.LRT
			elif has_left or has_right:
				grid[y][x] = RoomType.HORIZONTAL
			elif has_down:
				grid[y][x] = RoomType.LRB
			else:
				grid[y][x] = RoomType.FILLER
				
			print("new type: ",grid[y][x],"\n")


func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func spawn_room(room_type: RoomType, x: int, y: int):
	var room_scene : PackedScene = null
	match room_type:
		RoomType.HORIZONTAL:
			room_scene = horizontal_rooms.pick_random()
		RoomType.LRB:
			room_scene = lr_bottom_rooms.pick_random()
		RoomType.LRT:
			room_scene = lr_top_rooms.pick_random()
		RoomType.VERTICAL:
			room_scene = vertical_rooms.pick_random()
		RoomType.ARENA:
			room_scene = arena_rooms.pick_random()
		RoomType.FILLER:
			room_scene = filler_rooms.pick_random()

	if room_scene:
		var room = room_scene.instantiate()
		var room_pos = Vector2(x, y) * room_size
		room.position = room_pos
		background_node.add_child(room)

		# Reparent Foreground
		if room.has_node("ForegroundGroup"):
			var fg = room.get_node("ForegroundGroup")
			move_safely_to_parent(fg, foreground_node)

# Helper to reparent and keep transform
func move_safely_to_parent(node: Node2D, new_parent: Node):
	var global_xform = node.global_transform
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	node.global_transform = global_xform

func print_debug_minimap() -> void:
	print("\n=== GENERATED LEVEL ===")
	for y in range(grid_height):
		var line = ""
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			var char = "."
			if grid[y][x] != null:
				match grid[y][x]:
					RoomType.HORIZONTAL:
						char = "H"
					RoomType.LRB:
						char = "B"
					RoomType.LRT:
						char = "T"
					RoomType.VERTICAL:
						char = "V"
					RoomType.ARENA:
						char = "A"
					RoomType.FILLER:
						char = "."
			if main_path.has(pos):
				line += "[" + char + "]"
			else:
				line += " " + char + " "
		print(line)
	print("=======================\n")
	
func load_room_templates():
	load_templates_from("res://Scenes/RoomTemplates/Filler", filler_rooms)
	load_templates_from("res://Scenes/RoomTemplates/Horizontal", horizontal_rooms)
	load_templates_from("res://Scenes/RoomTemplates/LRB", lr_bottom_rooms)
	load_templates_from("res://Scenes/RoomTemplates/LRT", lr_top_rooms)
	load_templates_from("res://Scenes/RoomTemplates/Vertical", vertical_rooms)
	load_templates_from("res://Scenes/RoomTemplates/Arena", arena_rooms)

func load_templates_from(path: String, target_array: Array[PackedScene]) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Could not open folder: " + path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var scene_path = path + "/" + file_name
			var scene = ResourceLoader.load(scene_path)
			if scene and scene is PackedScene:
				target_array.append(scene)
		file_name = dir.get_next()
	dir.list_dir_end()
