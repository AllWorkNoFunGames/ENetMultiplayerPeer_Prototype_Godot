extends Control

@onready var InputBox = $TextBoxPanelContainer/MarginContainer/TabContainer/Chat/ChatContainer/InputBox
@onready var ChatHandler = get_node("/root/Multiplayer/Chat")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		#if !InputBox.has_focus:
			InputBox.grab_focus()

func _on_input_box_text_submitted(new_text: String) -> void:
	if new_text.strip_edges().is_empty():
		return

	ChatHandler.send_chat_from_local(new_text)
	InputBox.clear()
