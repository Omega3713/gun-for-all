extends char_state

func enter_state(char_node):
	super(char_node)
	char.velocity.y = char.JUMP_VELOCITY

func handle_input(_delta):
	if char.is_on_floor():
		char.change_state("IdleState")
		
	elif Input.get_axis("ui_left", "ui_right") != 0:
		char.change_state("MovingState")
