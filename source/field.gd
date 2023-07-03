@tool # so that _draw() works in the editor.
extends Node2D
class_name Field



var cards: Array = [null, null, null, null, null, null]

var player_name: String:
	set(new_player_name):
		player_name = new_player_name
		$Label.text = new_player_name
		$Label.rotation -= rotation

@export var zone_positions: Array[Vector2]
@export var zone_size:= Vector2(60, 87.5)
@export var zone_style_box: StyleBoxFlat




func make_label_horizontal() -> void:
	$Label.rotation -= rotation
	var distance: float = zone_positions[3].y + zone_size.y + 80
	var weight: float
	
	if fposmod($Label.rotation, TAU) > PI:
		if fposmod($Label.rotation, PI) < PI/2:
			weight = (fposmod($Label.rotation, PI/2) / (PI/2))
		else:
			weight = (1 - (fposmod($Label.rotation, PI/2)) / (PI/2))
	$Label.position.y = distance + weight * $Label.size.x


@rpc("call_local", "reliable")
func highlight_name() -> void:
	$Label.add_theme_stylebox_override(&"normal", zone_style_box)


@rpc("call_local", "reliable")
func unhighlight_name() -> void:
	$Label.remove_theme_stylebox_override(&"normal")


func _draw() -> void:
	for pos in zone_positions:
		draw_style_box(zone_style_box, Rect2(pos, zone_size))
