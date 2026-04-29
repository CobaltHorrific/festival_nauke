class_name BoardSlot
extends Node2D

const RADIUS: float = 60.0
const SNAP_DISTANCE: float = 75.0

var occupied_by: HexTile = null

@onready var polygon: Polygon2D = $Polygon2D

func _ready() -> void:
	_build_shape()
	_build_border()
	add_to_group("slots")

func _build_shape() -> void:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i)
		pts.append(Vector2(cos(angle), sin(angle)) * RADIUS)
	polygon.polygon = pts
	polygon.color = Color(0.12, 0.23, 0.37, 0.5)

func _build_border() -> void:
	var pts := PackedVector2Array()
	for i in 7:
		var angle := deg_to_rad(60.0 * (i % 6))
		pts.append(Vector2(cos(angle), sin(angle)) * RADIUS)
	var line := Line2D.new()
	line.points = pts
	line.default_color = Color("#000000")
	line.width = 3.0
	add_child(line)

func is_free() -> bool:
	return occupied_by == null

func highlight(on: bool) -> void:
	if on:
		polygon.color = Color(0.29, 0.87, 0.5, 0.5)
	else:
		polygon.color = Color(0.12, 0.23, 0.37, 0.5)
