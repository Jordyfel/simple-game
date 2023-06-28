extends Node2D



var deck: Deck
var players: Array = []
var fields: Array = []

var my_turn:= false
var player_index: int



func _ready() -> void:
	if multiplayer.is_server():
		Lobby.player_loaded()
	else:
		Lobby.player_loaded.rpc_id(1)


# Called only on the server.
func start_game() -> void:
	create_fields.rpc(Lobby.players)
	
	deck = Deck.new(players.size())
	for player in players:
		for i in range(4):
			draw_card(player)
	
	var id = players[randi_range(0, players.size() - 1)].id
	if id == 1:
		set_turn(true)
	else:
		set_turn.rpc_id(id, true)


@rpc
func set_turn(turn: bool) -> void:
	my_turn = turn
	for button in $Buttons.get_children():
		button.disabled = not turn


func end_turn(index: int) -> void:
	if index == 0:
		set_turn(false)
	else:
		set_turn.rpc_id(players[index].id, false)
	
	var starting_player_index: int = index + 1 if index + 1 < players.size() else 0
	
	if starting_player_index == 0:
		set_turn(true)
	else:
		set_turn.rpc_id(players[starting_player_index].id, true)


@rpc("call_local")
func create_fields(lobby_players_info: Dictionary) -> void:
	var keys = lobby_players_info.keys()
	keys.sort() # Need to make sure this array is the same on all clients.
	var table_radius: float = $Table.RADIUS
	var table_position: Vector2 = $Table.position
	for index in keys.size():
		var id = keys[index]
		if id == multiplayer.get_unique_id():
			player_index = index
		var field: Field = load("res://source/field.tscn").instantiate()
		var fraction:= (index as float) / keys.size() as float
		field.position = table_position + Vector2.from_angle(TAU * fraction) * table_radius * 0.5 
		add_child(field)
		field.player_name =  lobby_players_info[id]["name"]
		field.look_at(table_position)
		field.rotation += PI / 2
		fields.push_back(field)
		
		# This is here so that players and fields array have the same order on the server
		if multiplayer.is_server():
			players.push_back(Player.new(id, Lobby.players[id]["name"]))
			Lobby.players[id]["index"] = index


func draw_card(player: Player) -> void:
	var card:= deck.draw()
	player.hand.push_back(card)
	var card_info:= {"color": card.color, "shape": card.shape}
	if player.id == 1:
		$Hand.add_card(card_info)
	else:
		$Hand.add_card.rpc_id(player.id, card_info)


func move_card(card: HandCard, to_field_idx: int, to_zone_idx: int) -> void:
	const TWEEN_DURATION = 0.2
	
	if card == null:
		return
	
	var to_field = fields[to_field_idx]
	
	var pos_tween = get_tree().create_tween()
	var new_pos = to_field.to_global(to_field.zone_positions[to_zone_idx] + to_field.zone_size / 2)
	pos_tween.tween_property(card, "position", new_pos, TWEEN_DURATION)
	
	var rot_tween = get_tree().create_tween()
	var new_rotation = to_field.rotation
	rot_tween.tween_property(card, "rotation", new_rotation, TWEEN_DURATION)


@rpc("any_peer")
func play_from_hand(index_in_hand: int) -> void:
	var acting_player_index: int
	if multiplayer.get_remote_sender_id() == 0:
		acting_player_index = 0
	else:
		acting_player_index = Lobby.players[multiplayer.get_remote_sender_id()]["index"]
	
	if not fields[acting_player_index].cards.slice(0, 2).has(null):
		return
	
	if acting_player_index == 0:
		$Hand.remove_card(index_in_hand)
	else:
		$Hand.remove_card.rpc_id(multiplayer.get_remote_sender_id(), index_in_hand)
	
	var card: Card = players[acting_player_index].hand[index_in_hand]
	play_card.rpc({"color": card.color, "shape": card.shape}, acting_player_index)
	players[acting_player_index].hand.erase(card)


@rpc("call_local")
func play_card(card_info: Dictionary, field_index: int) -> void:
	var card:= HandCard.new(Card.new(card_info["color"], card_info["shape"]))
	var field = fields[field_index]
	var index = field.cards.slice(0, 2).find(null)
	field.cards[index] = card
	card.draggable = false
	card.position = field.to_global(field.zone_positions[index] + field.zone_size / 2)
	card.scale = Vector2(0.4, 0.4)
	card.rotation = field.rotation
	add_child(card)


func _on_card_placed(hand_card: HandCard, placement_position: Vector2) -> void:
	if placement_position.distance_to($Table.position) < $Table.RADIUS:
		if multiplayer.is_server():
			play_from_hand($Hand.cards.find(hand_card))
		else:
			play_from_hand.rpc_id(1, $Hand.cards.find(hand_card))


func _on_left_button_pressed() -> void:
	if my_turn:
		if multiplayer.is_server():
			action_push("left")
		else:
			action_push.rpc_id(1, "left")


func _on_right_button_pressed() -> void:
	if my_turn:
		if multiplayer.is_server():
			action_push("right")
		else:
			action_push.rpc_id(1, "right")


@rpc("any_peer")
func action_push(direction: String) -> void:
	var acting_player_index: int
	if multiplayer.get_remote_sender_id() == 0:
		acting_player_index = 0
	else:
		acting_player_index = Lobby.players[multiplayer.get_remote_sender_id()]["index"]
	
	push.rpc(acting_player_index, direction)


@rpc("call_local")
func push(action_player_index: int, direction: String) -> void:
	var card_index = 0 if direction == "left" else 1
	if fields[action_player_index].cards[card_index] == null:
		return
	
	var fields_with_a_card: Array[int] = []
	for field_index in fields.size():
		if fields[field_index].cards[card_index] != null:
			fields_with_a_card.push_back(field_index)
	
	if fields_with_a_card.size() == 1:
		return # Maybe end turn?
	
	var custom_range
	if direction == "left":
		# Iterate forward.
		custom_range = range(fields_with_a_card.size())
	elif direction == "right":
		# Iterate backward.
		custom_range = range(fields_with_a_card.size() - 1, -1, -1)
	
	var increment: int = 1 if direction == "left" else -1
	var temp: HandCard
	for index in custom_range:
		var next_field_index: int
		if index + increment > fields_with_a_card.size() - 1:
			next_field_index = 0
		else:
			next_field_index = fields_with_a_card[index + increment]
		
		if not temp:
			temp = fields[fields_with_a_card[index]].cards[card_index]
		
		move_card(temp, next_field_index, card_index)
		
		var swap = fields[next_field_index].cards[card_index]
		fields[next_field_index].cards[card_index] = temp
		temp = swap
	
	if multiplayer.is_server():
		end_turn(action_player_index)


func _on_swap_button_pressed() -> void:
	if my_turn:
		if multiplayer.is_server():
			action_swap()
		else:
			action_swap.rpc_id(1)


@rpc("any_peer")
func action_swap() -> void:
	var acting_player_index: int
	if multiplayer.get_remote_sender_id() == 0:
		acting_player_index = 0
	else:
		acting_player_index = Lobby.players[multiplayer.get_remote_sender_id()]["index"]
	
	swap_cards.rpc(acting_player_index, 0, 1)


@rpc("call_local")
func swap_cards(acting_player_index: int, from_zone: int, to_zone: int) -> void:
	move_card(fields[acting_player_index].cards[0], acting_player_index, 1)
	move_card(fields[acting_player_index].cards[1], acting_player_index, 0)
	
	var swap = fields[acting_player_index].cards[from_zone]
	fields[acting_player_index].cards[from_zone] = fields[acting_player_index].cards[to_zone]
	fields[acting_player_index].cards[to_zone] = swap


func _on_take_button_pressed() -> void:
	if my_turn:
		if multiplayer.is_server():
			action_take()
		else:
			action_take.rpc_id(1)


@rpc("any_peer")
func action_take() -> void:
	pass
