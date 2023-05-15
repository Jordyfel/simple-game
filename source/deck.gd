extends RefCounted
class_name Deck



var cards: Array = []



func _init() -> void:
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
	for color in colors:
		for shape in shapes:
			cards.push_back(Card.new(color, shape))
	cards.append_array(cards.duplicate())
	cards.shuffle()


func draw() -> Card:
	return cards.pop_back()


func get_size() -> int:
	return cards.size()
