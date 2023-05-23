extends RefCounted
class_name Deck



var cards: Array = []



func _init(number_of_players: int) -> void:
	var colors:= [
		Color.BLUE,
		Color.GREEN,
		Color.RED,
		Color.YELLOW,
	]
	var shapes = [
		Card.CardShape.CIRCLE,
		Card.CardShape.HEXAGON,
		Card.CardShape.SQUARE,
		Card.CardShape.TRIANGLE,
	]
	for i in range(number_of_players):
		for shape in shapes:
			cards.push_back(Card.new(colors[i], shape))
	#cards.append_array(cards.duplicate())
	cards.shuffle()


func draw() -> Card:
	return cards.pop_back()


func get_size() -> int:
	return cards.size()
