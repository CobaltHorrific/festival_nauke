class_name BoardSlot
extends Node2D

const RADIUS: float = 60.0
const SNAP_DISTANCE: float = 75.0

var occupied_by: HexTile = null

@onready var sprite: Sprite2D = $Sprite2D

var _tex_normal := preload("res://assets/sprites/slot_empty.png")
var _tex_hover := preload("res://assets/sprites/slot_hover.png")

func _ready() -> void:
	$Sprite2D.scale = Vector2(0.85, 0.85)
	add_to_group("slots")

func is_free() -> bool:
	return occupied_by == null

func highlight(on: bool) -> void:
	if sprite:
		sprite.texture = _tex_hover if on else _tex_normal
