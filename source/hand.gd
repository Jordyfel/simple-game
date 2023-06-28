extends Node2D



const SPACING = 20.0

var cards: Array = []

func _ready() -> void:
	pass


@rpc("call_local")
func add_card(card_info: Dictionary) -> void:
	var card = Card.new(card_info["color"], card_info["shape"])
	const CARDS_IN_COLUMN = 4
	var new_card = HandCard.new(card)
	@warning_ignore("integer_division")
	var card_x = ((SPACING + new_card.RECT.size.x) * (cards.size() / CARDS_IN_COLUMN)
			+ SPACING + new_card.RECT.size.x / 2)
	var card_y = ((SPACING + new_card.RECT.size.y) * (cards.size() % CARDS_IN_COLUMN)
			+ SPACING + new_card.RECT.size.y / 2)
	new_card.default_position = Vector2(card_x, card_y)
	new_card.position = new_card.default_position
	new_card.placed.connect(get_parent()._on_card_placed)
	add_child(new_card)
	cards.push_back(new_card)


@rpc("call_local")
func remove_card(index: int):
	for card_index in range(cards.size() - 1, index, -1):
		cards[card_index].default_position = cards[card_index - 1].default_position
		cards[card_index].position = cards[card_index - 1].default_position
	
	cards[index].queue_free()
	cards.remove_at(index)
