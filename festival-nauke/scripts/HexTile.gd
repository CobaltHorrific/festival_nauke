class_name HexTile
extends Area2D

const RADIUS: float = 60.0

var element: String = ""
var edges: Array = [0, 0, 0, 0, 0, 0]
var is_fixed: bool = false
var home_pos: Vector2 = Vector2.ZERO

signal tile_clicked(tile)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

var _textures := {
	"H": preload("res://assets/sprites/tile_H.png"),
	"O": preload("res://assets/sprites/tile_O.png"),
	"C": preload("res://assets/sprites/tile_C.png"),
	"N": preload("res://assets/sprites/tile_N.png"),
	"S": preload("res://assets/sprites/tile_S.png"),
}

func _ready() -> void:
	$Sprite2D.scale = Vector2(0.85, 0.85)
	_build_collision()
	add_to_group("tiles")

func setup(p_element: String, p_edges: Array, p_fixed: bool = false) -> void:
	element = p_element
	edges = p_edges
	is_fixed = p_fixed
	if is_inside_tree():
		_refresh_sprite()
		_refresh_bonds()

func _refresh_sprite() -> void:
	if sprite and _textures.has(element):
		sprite.texture = _textures[element]

func _input(event: InputEvent) -> void:
	if is_fixed:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse := get_global_mouse_position()
		var dist := mouse.distance_to(global_position)
		if dist < RADIUS:
			emit_signal("tile_clicked", self)
			get_viewport().set_input_as_handled()

func _build_collision() -> void:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i)
		pts.append(Vector2(cos(angle), sin(angle)) * RADIUS)
	collision.polygon = pts

func _refresh_bonds() -> void:
	for child in get_children():
		if child.name.begins_with("Bond_"):
			child.queue_free()
	
	for i in 6:
		var bond_count: int = edges[i]
		if bond_count == 0:
			continue
		
		var angle_a := deg_to_rad(60.0 * i)
		var angle_b := deg_to_rad(60.0 * ((i + 1) % 6))
		var vert_a := Vector2(cos(angle_a), sin(angle_a)) * RADIUS
		var vert_b := Vector2(cos(angle_b), sin(angle_b)) * RADIUS
		var mid := (vert_a + vert_b) / 2.0
		var edge_dir := (vert_b - vert_a).normalized()
		var perp := Vector2(-edge_dir.y, edge_dir.x) * 6.0
		var color := Color(0.29, 0.87, 0.5, 1.0)
		
		match bond_count:
			1:
				_add_line("Bond_%d_0" % i, Vector2.ZERO, mid, color, 5.0)
			2:
				_add_line("Bond_%d_0" % i, perp, mid + perp, color, 4.0)
				_add_line("Bond_%d_1" % i, -perp, mid - perp, color, 4.0)
			3:
				_add_line("Bond_%d_0" % i, Vector2.ZERO, mid, color, 6.0)
				_add_line("Bond_%d_1" % i, perp * 1.8, mid + perp * 1.8, color, 4.0)
				_add_line("Bond_%d_2" % i, -perp * 1.8, mid - perp * 1.8, color, 4.0)

func _add_line(line_name: String, from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var line := Line2D.new()
	line.name = line_name
	line.points = PackedVector2Array([from, to])
	line.default_color = color
	line.width = width
	add_child(line)
