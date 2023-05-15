extends RefCounted
class_name Card



enum CardShape {CIRCLE, SQUARE, TRIANGLE, HEXAGON}

var color: Color
var shape: CardShape



func _init(new_color: Color, new_shape: CardShape) -> void:
	color = new_color
	shape = new_shape
