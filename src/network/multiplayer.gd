extends Node

const PORT = 8000
const ADDRESS = "127.0.0.1"
const CHAT_HANDLER_SCRIPT := preload("res://src/network/chat_handler.gd")

# Reference to your player character
@export var player_scene: PackedScene

func _ready():
	_ensure_chat_handler()
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)

func _ensure_chat_handler() -> void:
	if has_node("Chat"):
		return

	var chat_handler := CHAT_HANDLER_SCRIPT.new()
	chat_handler.name = "Chat"
	add_child(chat_handler)
	
func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 32)
	if error != OK:
		StartWrapper.print_to_chat("Failed to host: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	# Host also spawns a player for themselves (ID 1)
	spawn_player(1)

func join_game():
	StartWrapper.print_to_chat("Attempting to connect to " + str(ADDRESS) + "...")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	
	if error != OK:
		retry_connection()
		return
		
	multiplayer.multiplayer_peer = peer

func on_player_connected(id):
	StartWrapper.print_to_chat("Player connected: " + str(id))
	# Only the server should handle spawning logic
	if multiplayer.is_server():
		spawn_player(id)

func on_player_disconnected(id):
	if get_node_or_null(str(id)):
		get_node(str(id)).queue_free()

func spawn_player(id):
	var level_scene = get_tree().current_scene
	var player = player_scene.instantiate()
	
	player.name = str(id) # Name must be identical across all peers

	if id == 1: 
		player.prettyName = "Server"
		player.networkPlayerNumber = 1
	else:
		player.prettyName = str(id)
		player.networkPlayerNumber = multiplayer.get_peers().size() + 1 #Host is not counted

	level_scene.get_node("./Players").add_child(player)
	var spawnpoint_name = "SpawnPoints/Point" + str(player.networkPlayerNumber)
	var spawn_point = level_scene.get_node(spawnpoint_name)
	player.global_position = spawn_point.global_position
	
func retry_connection():
	# Clean up the old peer before retrying
	multiplayer.multiplayer_peer = null
	StartWrapper.print_to_chat("Retrying in 1 second...")
	await get_tree().create_timer(1.0).timeout
	join_game()
