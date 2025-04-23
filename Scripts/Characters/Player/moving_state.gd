extends char_state

func handle_input(_delta):
	var direction = Input.get_axis("ui_left","ui_right")
	if direction != 0:
		char.velocity.x = direction * char.SPEED
	else:
		char.change_state("IdleState")
		
	if Input.is_action_just_pressed("ui_accept") and char.is_on_floor():
		char.change_state("JumpingState")
		
		
