extends Node

signal player_window_closed

var main_window: Window = null

func set_main_window(window: Window):
	main_window = window

func get_main_window() -> Window:
	return main_window
	
func on_subwindow_closed():
	get_tree().quit()
