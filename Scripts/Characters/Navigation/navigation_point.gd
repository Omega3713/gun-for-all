extends Marker2D
class_name NavigationPoint

# Store neighbors: each is a dictionary with the neighbor node and a "type" (walk, jump, fall)
var neighbors: Array = []

# Called automatically by the level generator's auto_connect_navpoints
func add_neighbor(other_navpoint: NavigationPoint, move_type: String) -> void:
	neighbors.append({
		"target": other_navpoint,
		"type": move_type
	})

# Optional: Find nearest neighbor of a certain type
func get_neighbors_by_type(move_type: String) -> Array:
	var filtered = []
	for neighbor in neighbors:
		if neighbor.type == move_type:
			filtered.append(neighbor.target)
	return filtered
