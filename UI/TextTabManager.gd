extends TabContainer

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var tab_index = event.keycode - KEY_1
			if tab_index < get_tab_count():
				current_tab = tab_index
				accept_event()
