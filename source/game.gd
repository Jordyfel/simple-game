extends Node2D



var deck: Deck

func _ready() -> void:
	if multiplayer.is_server():
		Lobby.player_loaded()
	else:
		Lobby.player_loaded.rpc_id(1)


# Called only on the server.
func start_game() -> void:
	deck = Deck.new()


func _on_card_placed(hand_card: HandCard, placement_position: Vector2) -> void:
	pass
