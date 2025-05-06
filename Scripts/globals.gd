extends Node

signal player_window_closed

const GAME_VERSION: String = "0.0.1.0"

var main_window: Window = null

# Roguelike stats
var stage_number: int = 1
var slimes_defeated: int = 0
var bosses_defeated: int = 0
var level_timer: float = 0.0  # Time spent on current level in seconds
var points: int = 0  # Total points available for spending

# Player stats
var player_health: int = 100  # Current HP
var player_max_health: int = 100  # Max HP
var player_damage_boost: int = 0  # Extra damage added to player's attacks
var player_max_health_boost: int = 0  # Extra max health gained through upgrades

func set_main_window(window: Window):
	main_window = window

func get_main_window() -> Window:
	return main_window

func on_subwindow_closed():
	get_tree().quit()

# --- Roguelike Stage Management ---
func reset_level_stats() -> void:
	slimes_defeated = 0
	bosses_defeated = 0
	level_timer = 0.0

func level_cleared() -> void:
	bosses_defeated += 1

func update_timer(delta: float) -> void:
	level_timer += delta

func calculate_points_for_stage(slimes_defeated: int, bosses_defeated: int, clear_time: float) -> int:
	var time_bonus = 0
	if clear_time <= 30.0:
		time_bonus = 100
	elif clear_time <= 45.0:
		time_bonus = 50
	else:
		time_bonus = 25

	var points = (slimes_defeated * 10) + (bosses_defeated * 100) + time_bonus
	return points

func reset_game_state() -> void:
	stage_number = 1
	slimes_defeated = 0
	bosses_defeated = 0
	level_timer = 0.0
	points = 0
	player_health = 100
	player_max_health = 100
	player_damage_boost = 0

# --- Upgrade Functions ---
func apply_heal(amount: int) -> void:
	player_health = min(player_health + amount, player_max_health)

func apply_damage_boost(amount: int) -> void:
	player_damage_boost += amount

func apply_max_health_boost(amount: int) -> void:
	player_max_health_boost += amount
	player_max_health += amount
	player_health += amount  # Optional: heal as well when max HP increases
