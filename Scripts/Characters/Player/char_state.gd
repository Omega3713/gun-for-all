extends Node
class_name char_state

var char

func enter_state(char_node):
	char = char_node
	
func exit_state():
	pass
	
func handle_input(_delta):
	pass
