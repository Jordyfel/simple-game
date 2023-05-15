extends Node2D
class_name Field



const BORDER_COLOR = Color("1f1f1f")
const ZONE_SIZE = Vector2(60, 87.5)
const ZONE_X = [0, 70, 140, 210]
const ZONE_Y = [0, 100]

var zone_rects: Array = []
var back_row: Array
var front_row: Array
var zone_style_box: StyleBoxFlat



func _init() -> void:
	for y in ZONE_Y:
		for x in ZONE_X:
			zone_rects.push_back(Rect2(Vector2(x, y), ZONE_SIZE))
	
	zone_style_box = StyleBoxFlat.new()
	zone_style_box.draw_center = false
	zone_style_box.set_border_width_all(2)
	zone_style_box.border_color = BORDER_COLOR
	zone_style_box.set_corner_radius_all(2)


func _draw() -> void:
	for rect in zone_rects:
		draw_style_box(zone_style_box, rect)
