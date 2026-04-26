extends Node

var args = OS.get_cmdline_args()

func _ready():
	if args.has("--server"):
		get_window().set_position(Vector2i(3957, 0))
		DisplayServer.window_set_title("Server")
		get_window().title = "Server"
		Multiplayer.host_game()
		
	if args.has("--client"):
		get_window().set_position(Vector2i(3957, 787))
		DisplayServer.window_set_title("Client")
		get_window().title = "Client"
		Multiplayer.join_game()
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_H:
			toggle_embedding()
		# Ensure Alt toggle doesn't trigger multiple times per press
		if event.keycode == KEY_ALT and not event.echo:
			toggle_mouse_capture()
			
func print_to_chat(message):
	var TextBox: Label = get_tree().root.get_node("StartLevel/MainInterface/TextBoxPanelContainer/MarginContainer/TabContainer/Chat/ChatContainer/TextBox")
	TextBox.text += message + "\n"

func toggle_embedding():
	var root = get_tree().root
	# Invert the current state
	var new_state = !root.gui_embed_subwindows
	
	# Apply to the viewport
	root.gui_embed_subwindows = new_state
	
	# Update Project Settings to maintain consistency
	ProjectSettings.set_setting("display/window/subwindows/embed_subwindows", new_state)
	
func toggle_mouse_capture():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
