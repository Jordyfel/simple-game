extends RefCounted
class_name Player



var id: int
var name: String
var hand: Array



func _init(new_id: int, new_name: String) -> void:
	id = new_id
	name = new_name
