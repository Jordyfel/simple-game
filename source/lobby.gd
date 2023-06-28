extends Node



signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT = 6969
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 8

var players:= {}
var player_info:= {"name": "Name"}
var players_loaded:= 0



func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address: String = "") -> int:
	if address == "":
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.set_multiplayer_peer(peer)
	return 0


func create_game() -> int:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.set_multiplayer_peer(peer)
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	return 0


func remove_multiplayer_peer() -> void:
	multiplayer.set_multiplayer_peer(null)


@rpc("any_peer")
func register_player(new_player_info: Dictionary) -> void:
	var new_player_id:= multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


@rpc("call_local")
func load_game() -> void:
	get_tree().change_scene_to_file("res://source/game.tscn")


@rpc("any_peer", "call_local")
func player_loaded() -> void:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()


# Called on the newly connected peer for each other peer, and on each other peer for the newly
# connected peer.
func _on_player_connected(id) -> void:
	register_player.rpc_id(id, player_info)


func _on_player_disconnected(id) -> void:
	player_info.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok() -> void:
	var peer_id:= multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail() -> void:
	remove_multiplayer_peer()


func _on_server_disconnected() -> void:
	remove_multiplayer_peer()
	server_disconnected.emit()
