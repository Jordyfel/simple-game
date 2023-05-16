extends Node2D



var deck: Deck
var players: Array = []
var fields: Array = []



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
	
	create_fields.rpc(Lobby.players)


@rpc("call_local")
func create_fields(lobby_players_info: Dictionary) -> void:
	var keys = lobby_players_info.keys()
	var table_radius: float = $Table.RADIUS
	var table_position: Vector2 = $Table.position
	for index in keys.size():
		var id = keys[index]
		var field:= Field.new(lobby_players_info[id]["name"])
		var fraction:= (index as float) / keys.size() as float
		field.position = table_position + Vector2.from_angle(TAU * fraction) * table_radius * 0.5 
		add_child(field)
		field.look_at(table_position)
		field.rotation += PI / 2


func draw_card(player: Player) -> void:
	var card:= deck.draw()
	player.hand.push_back(card)
	var card_info:= {"color": card.color, "shape": card.shape}
	if player.id == 1:
		$Hand.add_card(card_info)
	else:
		$Hand.add_card.rpc_id(player.id, card_info)


@rpc("any_peer")
func play_from_hand(index_in_hand: int):
	if multiplayer.get_remote_sender_id() == 0:
		$Hand.remove_card(index_in_hand)
	else:
		$Hand.remove_card.rpc_id(multiplayer.get_remote_sender_id(), index_in_hand)
	
	# then what


func _on_card_placed(hand_card: HandCard, placement_position: Vector2) -> void:
	if placement_position.distance_to($Table.position) < $Table.RADIUS:
		if multiplayer.is_server():
			play_from_hand($Hand.cards.find(hand_card))
		else:
			play_from_hand.rpc_id(1, $Hand.cards.find(hand_card))
