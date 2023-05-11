extends Control



func _ready() -> void:
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.player_disconnected.connect(_on_player_disconnected)
	Lobby.server_disconnected.connect(_on_server_disconnected)


func _on_join_button_pressed() -> void:
	if %NameEdit.text != "":
		Lobby.player_info["name"] = %NameEdit.text
	if %JoinButton.text == "Join Game":
		var error:= Lobby.join_game(%AddressEdit.text)
		if error:
			printerr(error_string(error))
			return
		%JoinButton.text = "Leave Game"
		$LobbyDisplay.show()
	else:
		%JoinButton.text = "Join Game"
		Lobby.remove_multiplayer_peer()
		$LobbyDisplay.hide()
		for lobby_element in %LobbyElementContainer.get_children():
			lobby_element.queue_free()


func _on_create_button_pressed() -> void:
	if %NameEdit.text != "":
		Lobby.player_info["name"] = %NameEdit.text
	if %CreateButton.text == "Create Game":
		var error:= Lobby.create_game()
		if error:
			printerr(error_string(error))
			return
		$LobbyDisplay.show()
		%StartButton.show()
		%CreateButton.text = "Stop"
	else:
		%CreateButton.text = "Create Game"
		Lobby.remove_multiplayer_peer()
		$LobbyDisplay.hide()
		%StartButton.hide()
		for lobby_element in %LobbyElementContainer.get_children():
			lobby_element.queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_player_connected(peer_id: int, player_info: Dictionary):
	var lobby_element:= LobbyElement.new(peer_id, player_info)
	%LobbyElementContainer.add_child(lobby_element)


func _on_player_disconnected(peer_id: int):
	for lobby_element in %LobbyElementContainer.get_children():
		if lobby_element.peer_id == peer_id:
			lobby_element.queue_free()


func _on_server_disconnected():
	for lobby_element in %LobbyElementContainer.get_children():
		lobby_element.queue_free()


func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		Lobby.load_game.rpc()



class LobbyElement:
	extends Label
	
	
	
	var peer_id: int
	var player_info: Dictionary
	
	
	
	func _init(new_peer_id: int, new_player_info: Dictionary) -> void:
		peer_id = new_peer_id
		player_info = new_player_info
		text = new_player_info["name"]
