extends Window
class_name ResultsWindow

signal continue_pressed

@onready var title_label: Label = $"MarginContainer/VBoxContainer/TitleLabel"
@onready var slimes_label: Label = $"MarginContainer/VBoxContainer/SlimeLabel"
@onready var boss_label: Label = $"MarginContainer/VBoxContainer/BossLabel"
@onready var time_label: Label = $"MarginContainer/VBoxContainer/TimeLabel"
@onready var points_label: Label = $"MarginContainer/VBoxContainer/PointsLabel"
@onready var total_points_label: Label = $"MarginContainer/VBoxContainer/TotalPointsLabel"
@onready var continue_button: Button = $"MarginContainer/VBoxContainer/ContinueButton"

# --- NEW for shop buttons ---
@onready var shop_heal_button: Button = $"MarginContainer/VBoxContainer/ShopContainer/HealButton"
@onready var shop_damage_button: Button = $"MarginContainer/VBoxContainer/ShopContainer/DamageButton"
@onready var shop_maxhp_button: Button = $"MarginContainer/VBoxContainer/ShopContainer/MaxHPButton"

var heal_cost = 100
var damage_cost = 300
var maxhp_cost = 500

var heal_purchased = false
var damage_purchased = false
var maxhp_purchased = false

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	shop_heal_button.pressed.connect(_on_heal_pressed)
	shop_damage_button.pressed.connect(_on_damage_pressed)
	shop_maxhp_button.pressed.connect(_on_maxhp_pressed)

	show_results(
		Globals.stage_number,
		Globals.slimes_defeated,
		Globals.bosses_defeated,
		Globals.level_timer
	)

func show_results(stage_number: int, slimes_defeated: int, bosses_defeated: int, clear_time: float) -> void:
	
	var points = Globals.calculate_points_for_stage(slimes_defeated,bosses_defeated,clear_time)
	Globals.points += points

	title_label.text = "Stage %d Complete!" % stage_number
	slimes_label.text = "Slimes Defeated: %d" % slimes_defeated
	boss_label.text = "Bosses Defeated: %d" % bosses_defeated
	time_label.text = "Clear Time: %.2f seconds" % clear_time
	points_label.text = "Earned Points: %d" % points
	total_points_label.text = "Total Points: %d" % Globals.points

	update_shop_buttons()

func update_shop_buttons() -> void:
	# Disable shop buttons if already purchased or not enough points
	shop_heal_button.text = "+20 HP - %d Points" % heal_cost
	shop_damage_button.text = "+5 DMG - %d Points" % damage_cost
	shop_maxhp_button.text = "+10 MAXHP - %d Points" % maxhp_cost
	shop_heal_button.disabled = heal_purchased or Globals.points < heal_cost
	shop_damage_button.disabled = damage_purchased or Globals.points < damage_cost
	shop_maxhp_button.disabled = maxhp_purchased or Globals.points < maxhp_cost

func _on_heal_pressed() -> void:
	if Globals.points >= heal_cost and not heal_purchased:
		Globals.apply_heal(20)
		Globals.points -= heal_cost
		heal_purchased = true
		update_shop_buttons()
		update_total_points()

func _on_damage_pressed() -> void:
	if Globals.points >= damage_cost and not damage_purchased:
		Globals.apply_damage_boost(5)
		Globals.points -= damage_cost
		damage_purchased = true
		update_shop_buttons()
		update_total_points()

func _on_maxhp_pressed() -> void:
	if Globals.points >= maxhp_cost and not maxhp_purchased:
		Globals.apply_max_health_boost(10)
		Globals.points -= maxhp_cost
		maxhp_purchased = true
		update_shop_buttons()
		update_total_points()

func update_total_points() -> void:
	total_points_label.text = "Total Points: %d" % Globals.points

func _on_continue_pressed() -> void:
	continue_pressed.emit()
	await get_tree().process_frame 
	queue_free()
