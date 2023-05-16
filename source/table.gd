extends Node2D



const RADIUS:= 400.0



func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color.DARK_GRAY)
