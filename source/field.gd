extends Node2D
class_name Field



const BORDER_COLOR = Color("1f1f1f")
const ZONE_SIZE = Vector2(60, 87.5)
const ZONE_X = [-135, -65, 5, 75]
const ZONE_Y = [0, 100]

var zone_rects: Array = []
var back_row: Array
var front_row: Array
var zone_style_box: StyleBoxFlat
var player_name: String



func _init(new_player_name) -> void:
	scale = Vector2(0.8, 0.8)
	player_name = new_player_name
	for y in ZONE_Y:
		for x in ZONE_X:
			zone_rects.push_back(Rect2(Vector2(x, y), ZONE_SIZE))
	# temp
	zone_rects.remove_at(3)
	zone_rects.remove_at(0)
	
	zone_style_box = StyleBoxFlat.new()
	zone_style_box.draw_center = false
	zone_style_box.set_border_width_all(3)
	zone_style_box.border_color = BORDER_COLOR
	zone_style_box.set_corner_radius_all(2)


func _ready() -> void:
	var label:= Label.new()
	label.text = player_name
	label.position = Vector2(0, 200) # temp
	add_child(label)


func _draw() -> void:
	for rect in zone_rects:
		draw_style_box(zone_style_box, rect)
