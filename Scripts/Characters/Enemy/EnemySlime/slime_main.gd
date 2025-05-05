extends CharacterBody2D
class_name SlimeMain

signal slime_defeated  # Signal emitted when the slime dies

@export var max_health: int = 30
@export var move_speed: float = 150.0
@export var base_touch_damage: int = 5
@export var knockback_strength: float = 300.0
@export var aggro_distance: float = 300.0
@export var touch_damage_interval: float = 1.0  # NEW: seconds between each touch hit

@onready var player: Node2D = null
@onready var navigator = $SlimeNavigator
@onready var hurtbox = $SlimeHurtbox
@onready var slime_sprite = $SlimeSprite

var current_state: EnemyState
var health: int
var touch_damage: int
var touching_player: Node2D = null
var touch_damage_timer: float = 0.0

func _ready() -> void:
	# Scale touch damage based on current stage (after stage 5)
	var scaling = max(0, Globals.stage_number - 5)
	touch_damage = base_touch_damage + scaling * 2

	health = max_health
	player = get_node_or_null("/root/Main/LevelGenerator/Entity/Player")

	navigator.enemy_body = self
	navigator.initialize()

	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.body_exited.connect(_on_hurtbox_body_exited)

	change_state("SlimeIdleState")

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	update_slime_animation()

func _process(delta: float) -> void:
	if current_state:
		current_state.handle_input(delta)

	# Handle continuous touch damage with cooldown
	if touching_player:
		touch_damage_timer -= delta
		if touch_damage_timer <= 0.0:
			if touching_player.is_inside_tree() and touching_player.has_method("take_damage"):
				touching_player.take_damage(touch_damage)
				if touching_player.has_method("apply_knockback"):
					var knockback_dir = (touching_player.global_position - global_position).normalized()
					touching_player.apply_knockback(knockback_dir * knockback_strength)
			touch_damage_timer = touch_damage_interval

func change_state(new_state_name: String) -> void:
	if current_state:
		current_state.exit_state()
	current_state = get_node_or_null(new_state_name)
	if current_state:
		current_state.enter_state(self)

func update_slime_animation():
	if abs(velocity.x) > 1:
		if not slime_sprite.is_playing():
			slime_sprite.play("idlewalk")
	else:
		slime_sprite.stop()
		slime_sprite.frame = 0

	if velocity.x > 0:
		slime_sprite.flip_h = false
	elif velocity.x < 0:
		slime_sprite.flip_h = true

func flash():
	modulate = Color(1, 0.5, 0.5)  # Light red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Normal again

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO):
	health -= amount
	flash()
	
	# Apply knockback
	velocity = knockback_dir.normalized() * knockback_strength

	if health <= 0:
		die()

func die() -> void:
	emit_signal("slime_defeated") 
	queue_free()

func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		touching_player = body
		touch_damage_timer = 0.0  # Deal damage immediately on touch

func _on_hurtbox_body_exited(body: Node) -> void:
	if body == touching_player:
		touching_player = null
