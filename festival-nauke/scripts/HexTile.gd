class_name HexTile
extends Area2D

const RADIUS: float = 60.0

var element: String = ""
var edges: Array = [0, 0, 0, 0, 0, 0]
var is_fixed: bool = false
var home_pos: Vector2 = Vector2.ZERO

signal tile_clicked(tile)

@onready var polygon: Polygon2D = $Polygon2D
@onready var label: Label = $Label
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	_build_hex_shape()
	_refresh_visuals()
	add_to_group("tiles")

func setup(p_element: String, p_edges: Array, p_fixed: bool = false) -> void:
	element = p_element
	edges = p_edges
	is_fixed = p_fixed
	if is_inside_tree():
		_refresh_visuals()

func _input(event: InputEvent) -> void:
	if is_fixed:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse := get_global_mouse_position()
		var dist := mouse.distance_to(global_position)
		if dist < RADIUS:
			emit_signal("tile_clicked", self)
			get_viewport().set_input_as_handled()

func _build_hex_shape() -> void:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i)
		pts.append(Vector2(cos(angle), sin(angle)) * RADIUS)
	polygon.polygon = pts
	collision.polygon = pts

func _refresh_visuals() -> void:
	if label:
		label.text = element
	if polygon:
		match element:
			"C": polygon.color = Color("2d2d2d")
			"H": polygon.color = Color("c8c8c8")
			"O": polygon.color = Color("c0392b")
			"N": polygon.color = Color("2471a3")
			"S": polygon.color = Color("f1c40f")
			_:   polygon.color = Color("1e3a5f")
