extends Control

@onready

var InputBox = $TextBoxPanelContainer/MarginContainer/TabContainer/Chat/ChatContainer/InputBox

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		#if !InputBox.has_focus:
			InputBox.grab_focus()

func send_message(content: String) -> void:
	print("Message sent: " + content)
	# Logic for UI updates or networking goes here

func _on_input_box_text_submitted(new_text: String) -> void:
	if new_text != "":
		
#		rpc(send_message(new_text),)
		InputBox.clear() # Optional: Clear the box after sending
