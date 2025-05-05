extends Node

var nav_points: Array[NavigationPoint] = []

func generate_navigation_from(room_ground: TileMap):
	nav_points.clear()
	
	# Example: scan every tile in the ground layer
	for y in range(room_ground.get_used_rect().size.y):
		for x in range(room_ground.get_used_rect().size.x):
			var tile_pos = Vector2i(x, y) + room_ground.get_used_rect().position
			var tile = room_ground.get_cell_tile_data(0, tile_pos)
			
			if tile and is_walkable(tile):
				var world_pos = room_ground.map_to_local(tile_pos)
				var nav_point = NavigationPoint.new()
				nav_point.position = world_pos
				nav_points.append(nav_point)
	
	# [Later] Link neighbors (walk, jump, fall)

func is_walkable(tile_data) -> bool:
	# (you can customize more based on collision mask, material, or autotile IDs)
	return true
