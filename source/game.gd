extends Node2D



var deck: Deck
var players: Array = []



func _ready() -> void:
	if multiplayer.is_server():
		Lobby.player_loaded()
	else:
		Lobby.player_loaded.rpc_id(1)


# Called only on the server.
func start_game() -> void:
	deck = Deck.new()
	for id in Lobby.players:
		players.push_back(Player.new(id, Lobby.players[id]["name"]))
	for player in players:
		for i in range(8):
			draw_card(player)
	
	var field:= Field.new()
	field.position = Vector2(660, 620)
	add_child(field)


func draw_card(player: Player) -> void:
	var card:= deck.draw()
	player.hand.push_back(card)
	var card_info:= {"color": card.color, "shape": card.shape}
	if player.id == 1:
		$Hand.add_card(card_info)
	else:
		$Hand.add_card.rpc_id(player.id, card_info)


func _on_card_placed(_hand_card: HandCard, _placement_position: Vector2) -> void:
	pass
