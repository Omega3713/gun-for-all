extends Window
class_name GameOverWindow

signal restart_requested

@onready var title_label: Label = $"MarginContainer/VBoxContainer/TitleLabel"
@onready var round_label: Label = $"MarginContainer/VBoxContainer/RoundLabel"
@onready var restart_button: Button = $"MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RestartButton"
@onready var quit_button: Button = $"MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/QuitButton"

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	show_game_over(Globals.stage_number)

func show_game_over(stage_reached: int) -> void:
	title_label.text = "Game Over"
	round_label.text = "You reached Stage %d" % stage_reached
	restart_button.text = "Restart"
	quit_button.text = "Quit"

func _on_restart_pressed() -> void:
	restart_requested.emit()
	queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()
