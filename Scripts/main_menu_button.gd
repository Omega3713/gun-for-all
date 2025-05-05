extends Button

@export var hover_scale: float = 1.1
var original_scale: Vector2

func _ready():
	original_scale = scale

func _on_mouse_entered():
	scale = original_scale * hover_scale

func _on_mouse_exited():
	scale = original_scale
