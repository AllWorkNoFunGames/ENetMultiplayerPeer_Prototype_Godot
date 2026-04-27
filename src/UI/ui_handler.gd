extends Control

@onready

var InputBox = $TextBoxPanelContainer/MarginContainer/TabContainer/Chat/ChatContainer/InputBox

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		#if !InputBox.has_focus:
			InputBox.grab_focus()

func _filter_chat_message(raw_text: String) -> String:
	var clean := raw_text.strip_edges()
	clean = clean.replace("\n", " ").replace("\r", " ")
	return clean

@rpc("any_peer", "call_local", "reliable")
func submit_chat_message(raw_text: String) -> void:
	# Only the server is allowed to accept and fan-out client messages.
	if !multiplayer.is_server():
		return

	var clean := _filter_chat_message(raw_text)
	if clean.is_empty():
		return

	var sender_id := multiplayer.get_remote_sender_id()

	broadcast_chat_message.rpc(sender_id, clean)

@rpc("authority", "call_local", "reliable")
func broadcast_chat_message(sender_id: int, content: String) -> void:
	StartWrapper.print_to_chat("[%s] %s" % [str(sender_id), content])

func _on_input_box_text_submitted(new_text: String) -> void:
	var clean := _filter_chat_message(new_text)
	if clean.is_empty():
		return

	if multiplayer.is_server():
		broadcast_chat_message.rpc(multiplayer.get_unique_id(), clean)
	else:
		# Send only to the host; the host validates and rebroadcasts.
		submit_chat_message.rpc_id(1, clean)

	InputBox.clear()
