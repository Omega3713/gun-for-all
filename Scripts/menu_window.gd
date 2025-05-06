extends Window
class_name MenuWindow  # Optional: nice if you want to preload as MenuWindow later

signal menu_action_selected(start_game: bool)

@onready var start_button = $Panel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/StartButton
@onready var quit_button = $Panel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/QuitButton
@onready var version_label = $"Panel/MarginContainer2/VersionLabel"

func _ready():
	start_button.grab_focus()  # So keyboard works immediately
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	self.title = "Gun for All (v" + Globals.GAME_VERSION + ")"
	version_label.text = Globals.GAME_VERSION

func _on_start_pressed():
	menu_action_selected.emit(true)
	queue_free()  # Close the menu

func _on_quit_pressed():
	menu_action_selected.emit(false) 
	queue_free()  # Close the menu
