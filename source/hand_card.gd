extends Node2D
class_name HandCard



signal placed(hand_card: HandCard, placement_position: Vector2)

const RECT = Rect2(Vector2(-60, -87.5), Vector2(120, 175))
const BORDER_COLOR = Color("1f1f1f")

var card: Card
var style_box: StyleBoxFlat
var default_position: Vector2
var draggable:= true
var dragging:= false



func _init(new_card: Card) -> void:
	card = new_card
	style_box = StyleBoxFlat.new()
	style_box.set_bg_color(card.color)
	style_box.set_corner_radius_all(4)
	style_box.set_border_width_all(4)
	style_box.set_border_color(BORDER_COLOR)
	style_box.set_border_blend(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if RECT.has_point(to_local(event.position)):
			if draggable:
				dragging = true
	if event.is_action_released("left_click"):
		if dragging == true:
			dragging = false
			placed.emit(self, event.position)
			position = default_position


func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position()


func _draw() -> void:
	draw_style_box(style_box, RECT)
	const CENTER = Vector2.ZERO
	const RAIDUS = 40.0
	const WIDTH = 4.0
	const ANTIALIASED = true
	var start_angle: float
	var end_angle: float
	var point_count: int
	match card.shape:
		Card.CardShape.CIRCLE:
			start_angle = 0
			end_angle = TAU
			point_count = 40
		Card.CardShape.SQUARE:
			start_angle = -PI/4
			end_angle = TAU - PI/4
			point_count = 5
		Card.CardShape.TRIANGLE:
			start_angle = -PI/2
			end_angle = TAU - PI/2
			point_count = 4
		Card.CardShape.HEXAGON:
			start_angle = 0
			end_angle = TAU
			point_count = 7
	
	draw_arc(CENTER, RAIDUS, start_angle, end_angle, point_count, BORDER_COLOR, WIDTH, ANTIALIASED)
