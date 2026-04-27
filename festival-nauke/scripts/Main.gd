extends Node2D

const HexTileSCN = preload("res://scenes/HexTile.tscn")

var dragged_tile: HexTile = null
var drag_offset: Vector2 = Vector2.ZERO

const TEST_POOL := [
	["O", [0, 1, 0, 0, 1, 0]],
	["H", [0, 0, 0, 1, 0, 0]],
	["H", [0, 0, 0, 1, 0, 0]],
]

func _ready() -> void:
	_spawn_test_tiles()

func _spawn_test_tiles() -> void:
	var center_x: float = get_viewport_rect().size.x / 2.0
	var pool_y: float = 800.0
	var spacing: float = 150.0
	
	for i in TEST_POOL.size():
		var tile: HexTile = HexTileSCN.instantiate()
		add_child(tile)
		var offset := (i - (TEST_POOL.size() - 1) / 2.0) * spacing
		var pos := Vector2(center_x + offset, pool_y)
		tile.global_position = pos
		tile.home_pos = pos
		tile.setup(TEST_POOL[i][0], TEST_POOL[i][1])
		tile.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile: HexTile) -> void:
	dragged_tile = tile
	drag_offset = get_global_mouse_position() - tile.global_position
	move_child(tile, get_child_count() - 1)

func _process(_delta: float) -> void:
	if dragged_tile != null:
		var new_pos = get_global_mouse_position() - drag_offset
		dragged_tile.global_position = new_pos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragged_tile != null:
			dragged_tile.global_position = dragged_tile.home_pos
			dragged_tile = null
