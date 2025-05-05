extends char_state

func handle_input(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Handle Coyote Time
	if char.is_on_floor():
		char.coyote_timer = char.coyote_time
	else:
		char.coyote_timer -= delta
		
	if !char.is_on_floor():
		char.player_sprite.play("jumping")
		if char.velocity.y < 0:
			char.player_sprite.frame = 0  # Going up → first frame
		elif char.velocity.y > 0:
			char.player_sprite.frame = 1  # Falling down → second frame

	# Handle Jump Buffer
	if Input.is_action_just_pressed("ui_accept"):
		char.jump_buffer_timer = char.jump_buffer_time
	else:
		char.jump_buffer_timer -= delta

	if direction != 0:
		if char.is_on_floor():
			char.player_sprite.play("running")
		char.velocity.x = direction * char.SPEED
	else:
		char.change_state("IdleState")

	# Jump if conditions are right
	if (char.is_on_floor() or char.coyote_timer > 0.0) and char.jump_buffer_timer > 0.0:
		char.change_state("JumpingState")
