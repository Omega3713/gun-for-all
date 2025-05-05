extends Node2D

# Define the types of rooms
const RoomType = preload("res://Scripts/room_types.gd").RoomType

# Which kind of room this is
@export var room_type: RoomType = RoomType.FILLER
@export var background_group_path: NodePath
@export var foreground_group_path: NodePath

# Stores entrances (you'll auto-fill this later in _ready())
var entrances := {}

func _ready() -> void:
	# Auto-detect entrance points
	entrances.clear()
	for entrance in get_node("Markers/EntrancePoints").get_children():
		if entrance.visible:
			entrances[entrance.name] = entrance.global_position

func get_background_group() -> Node2D:
	return get_node(background_group_path)

func get_foreground_group() -> Node2D:
	return get_node(foreground_group_path)
