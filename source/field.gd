@tool # so that _draw() works in the editor.
extends Node2D
class_name Field



var cards: Array = [null, null, null, null, null, null]


var player_name: String:
	set(new_player_name):
		player_name = new_player_name
		$Label.text = new_player_name

@export var zone_positions: Array[Vector2]
@export var zone_size:= Vector2(60, 87.5)
@export var zone_style_box: StyleBoxFlat



func _draw() -> void:
	for pos in zone_positions:
		draw_style_box(zone_style_box, Rect2(pos, zone_size))
