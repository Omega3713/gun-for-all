extends Area2D

@export var speed: float = 2000
@export var damage: int = 10
var direction: Vector2 = Vector2.ZERO
var shooter = null

func _ready():
	rotation = direction.angle()

func _physics_process(delta):
	var from := global_position
	var to = from + direction * speed * delta

	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1  # adjust if needed

	var result := get_world_2d().direct_space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		if collider != shooter and (collider.is_in_group("player") or collider.is_in_group("enemy")):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
		queue_free()
	else:
		global_position = to
