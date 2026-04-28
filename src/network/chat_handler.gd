extends Node

var http = Multiplayer.get_node("HTTPRequest")


func _filter_chat_message(raw_text: String) -> String:
	var clean := raw_text.strip_edges()
	clean = clean.replace("\n", " ").replace("\r", " ")
	return clean

func send_chat_from_local(raw_text: String) -> void:
	var clean := _filter_chat_message(raw_text)
	if clean.is_empty():
		return

	if multiplayer.is_server():
		broadcast_chat_message.rpc(multiplayer.get_unique_id(), clean)
	else:
		# Send only to the host; the host validates and rebroadcasts.
		submit_chat_message.rpc_id(1, clean)

@rpc("any_peer", "call_local", "reliable")
func submit_chat_message(raw_text: String) -> void:
	# Only the server is allowed to accept and fan-out client messages.
	if !multiplayer.is_server():
		return

	var clean := _filter_chat_message(raw_text)
	if clean.is_empty():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()

	broadcast_chat_message.rpc(sender_id, clean)

@rpc("authority", "call_local", "reliable")
func broadcast_chat_message(sender_id: int, content: String) -> void:
	StartWrapper.print_to_chat("[%s] %s" % [str(sender_id), content])
	# This RPC runs on every peer; persist to backend only from the server.
	if multiplayer.is_server():
		http.post_json({"type": "chat", "sender":str(sender_id), "message": str(content)})
