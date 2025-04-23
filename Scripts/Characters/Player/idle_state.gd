extends char_state

func enter_state(char_node):
	super(char_node)
	char.velocity.x = 0
	
func handle_input(_delta):
	if Input.is_action_just_pressed("ui_accept") and char.is_on_floor():
		char.change_state("JumpingState")
		
	elif Input.get_axis("ui_left", "ui_right") != 0:
		char.change_state("MovingState")
