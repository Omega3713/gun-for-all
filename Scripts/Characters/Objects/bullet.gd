extends Area2D
class_name Bullet

@export var speed: float = 2000
@export var damage: int = 10
var direction: Vector2 = Vector2.ZERO
var shooter = null

@onready var sprite: AnimatedSprite2D = $BulletSprite

var is_colliding = false

func _ready():
	rotation = direction.angle()
	sprite.offset.x = 0

	# Play correct initial animation based on shooter
	if shooter and shooter.is_in_group("enemy"):
		sprite.play("enemy_fire")
	else:
		sprite.play("fire")

	sprite.frame = 0
	sprite.pause()  # We'll manually control frame stepping

	# --- NEW: Immediately check for collision on spawn
	check_immediate_hit()

func _physics_process(delta):
	if is_colliding:
		return  # Don't move if already collided

	# Handle muzzle flash lasting only 1 frame
	sprite.frame = 1

	var from := global_position
	var to = from + direction * speed * delta

	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1  # Adjust if needed (your enemies are probably on 1)

	var result = get_world_2d().direct_space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		if collider != shooter and (collider.is_in_group("player") or collider.is_in_group("enemy")):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
		hit()
	else:
		global_position = to

func hit():
	is_colliding = true
	sprite.play("hit_spark")
	sprite.offset.x = -8
	await sprite.animation_finished
	queue_free()

# --- NEW function
func check_immediate_hit():
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1
	query.exclude = [self]

	var result = get_world_2d().direct_space_state.intersect_point(query)

	for res in result:
		var collider = res.collider
		if collider and collider != shooter:
			if collider.is_in_group("player") or collider.is_in_group("enemy"):
				if collider.has_method("take_damage"):
					collider.take_damage(damage)
				hit()
				break
