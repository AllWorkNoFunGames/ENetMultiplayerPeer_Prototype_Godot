extends Label

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			copy_to_clipboard()

func copy_to_clipboard():
	DisplayServer.clipboard_set(text)
