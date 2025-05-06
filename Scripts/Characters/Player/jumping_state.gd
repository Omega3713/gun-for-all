extends char_state

func enter_state(char_node):
	super(char_node)
	char.player_sprite.play("jumping")
	char.velocity.y = char.JUMP_VELOCITY
	char.coyote_timer = 0.0
	char.jump_buffer_timer = 0.0

func handle_input(delta):
	# Variable Jump Height
	if char.velocity.y < 0:
		char.player_sprite.frame = 0  # Going up → first frame
	elif char.velocity.y > 0:
		char.player_sprite.frame = 1  # Falling down → second frame
		
	if not Input.is_action_pressed("ui_accept"):
		if char.velocity.y < 0:
			# Released early -> cut jump height
			char.velocity.y *= 0.5
		elif char.velocity.y > -20 and char.velocity.y < 20:
			# Released late near peak -> force downward
			char.velocity.y = 200  # Start falling fast


	if char.is_on_floor():
		char.change_state("IdleState")
	elif Input.get_axis("ui_left", "ui_right") != 0:
		char.change_state("MovingState")
