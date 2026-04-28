extends Node2D

const HexTileSCN = preload("res://scenes/HexTile.tscn")
const BoardSlotSCN = preload("res://scenes/BoardSlot.tscn")

const LEVEL_PATH := "res://data/levels/level_01_water.json"

var current_level: Dictionary = {}
var dragged_tile: HexTile = null
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_level = LevelLoader.load_level(LEVEL_PATH)
	if current_level.is_empty():
		push_error("Level nije ucitan, prekidam.")
		return
	print("Ucitan level: ", current_level.get("name", "?"))
	_spawn_slots()
	_spawn_tiles()

func _spawn_slots() -> void:
	var slots_data: Array = current_level.get("slots", [])
	for slot_data in slots_data:
		var slot: BoardSlot = BoardSlotSCN.instantiate()
		add_child(slot)
		slot.global_position = Vector2(slot_data.x, slot_data.y)

func _spawn_tiles() -> void:
	var pool_data: Array = current_level.get("pool", [])
	var center_x: float = get_viewport_rect().size.x / 2.0
	var pool_y: float = 750.0
	var spacing: float = 150.0
	
	for i in pool_data.size():
		var tile: HexTile = HexTileSCN.instantiate()
		add_child(tile)
		var offset := (i - (pool_data.size() - 1) / 2.0) * spacing
		var pos := Vector2(center_x + offset, pool_y)
		tile.global_position = pos
		tile.home_pos = pos
		var element: String = pool_data[i].element
		var edges: Array = pool_data[i].edges
		tile.setup(element, edges)
		tile.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile: HexTile) -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.occupied_by == tile:
			slot.occupied_by = null
			slot.highlight(false)
	dragged_tile = tile
	drag_offset = get_global_mouse_position() - tile.global_position
	move_child(tile, get_child_count() - 1)

func _process(_delta: float) -> void:
	if dragged_tile == null:
		return
	var mouse_pos := get_global_mouse_position()
	dragged_tile.global_position = mouse_pos - drag_offset
	var nearest := _find_nearest_free_slot(mouse_pos)
	for slot in get_tree().get_nodes_in_group("slots"):
		slot.highlight(slot == nearest)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragged_tile == null:
			return
		var mouse_pos := get_global_mouse_position()
		var nearest := _find_nearest_free_slot(mouse_pos)
		if nearest != null:
			dragged_tile.global_position = nearest.global_position
			nearest.occupied_by = dragged_tile
			nearest.highlight(false)
		else:
			dragged_tile.global_position = dragged_tile.home_pos
		dragged_tile = null
		_check_win()

func _find_nearest_free_slot(pos: Vector2) -> BoardSlot:
	var nearest: BoardSlot = null
	var nearest_dist: float = BoardSlot.SNAP_DISTANCE
	for slot in get_tree().get_nodes_in_group("slots"):
		if not slot.is_free():
			continue
		var dist := pos.distance_to(slot.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = slot
	return nearest

func _check_win() -> void:
	var slots := get_tree().get_nodes_in_group("slots")
	for slot in slots:
		if slot.is_free():
			return
	if _validate_edges(slots):
		print("WIN! Molekul je ispravan!")
	else:
		print("Svi slotovi popunjeni ali veze se ne poklapaju!")

func _validate_edges(slots: Array) -> bool:
	const NEIGHBOR_DIST: float = 150.0
	for i in slots.size():
		var slot_a: BoardSlot = slots[i]
		var tile_a: HexTile = slot_a.occupied_by
		for j in slots.size():
			if i == j:
				continue
			var slot_b: BoardSlot = slots[j]
			var tile_b: HexTile = slot_b.occupied_by
			var dist := slot_a.global_position.distance_to(slot_b.global_position)
			if dist > NEIGHBOR_DIST:
				continue
			var edge_idx := _get_edge_index(slot_a.global_position, slot_b.global_position)
			var opposite_idx := (edge_idx + 3) % 6
			if tile_a.edges[edge_idx] != tile_b.edges[opposite_idx]:
				return false
	return true

func _get_edge_index(from: Vector2, to: Vector2) -> int:
	var dir := (to - from).normalized()
	var best_idx := 0
	var best_dot := -2.0
	for i in 6:
		var angle := deg_to_rad(30.0 + 60.0 * i)
		var edge_dir := Vector2(cos(angle), sin(angle))
		var dot := dir.dot(edge_dir)
		if dot > best_dot:
			best_dot = dot
			best_idx = i
	return best_idx
