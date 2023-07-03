@tool # so that _draw() works in the editor.
extends Node2D



const RADIUS:= 400.0

@export var color: Color:
	set(new_color):
		color = new_color
		queue_redraw()



func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, color)
