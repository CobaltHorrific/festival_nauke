extends Node2D

const HexTileSCN = preload("res://scenes/HexTile.tscn")
const BoardSlotSCN = preload("res://scenes/BoardSlot.tscn")
const LEVELS := [
	"res://data/levels/level_01_water.json",
	"res://data/levels/level_02_co2.json",
	"res://data/levels/level_03_ammonia.json",
	"res://data/levels/level_04_methane.json",
	"res://data/levels/level_05_metanal.json",
	"res://data/levels/level_06_metanol.json",
	"res://data/levels/level_07_metilamina.json",
	"res://data/levels/level_08_etanol.json",
]

const SFX_PICKUP = preload("res://assets/sounds/sfx/pickup.wav")
const SFX_SNAP = preload("res://assets/sounds/sfx/snap.wav")
const SFX_ERROR = preload("res://assets/sounds/sfx/error.wav")
const SFX_WIN = preload("res://assets/sounds/sfx/win.wav")
const SFX_CLICK = preload("res://assets/sounds/sfx/klik.wav")
const MUSIC = preload("res://assets/sounds/music/music_loop.ogg")

const LEVEL_BACKGROUNDS := [
	preload("res://assets/sprites/background_blue.png"),
	preload("res://assets/sprites/background_yellow.png"),
	preload("res://assets/sprites/background_purple.png"),
	preload("res://assets/sprites/background_red.png"),
	preload("res://assets/sprites/background_blue.png"),
	preload("res://assets/sprites/background_yellow.png"),
	preload("res://assets/sprites/background_purple.png"),
	preload("res://assets/sprites/background_red.png"),
]

var current_level_index: int = 0
var current_level: Dictionary = {}
var dragged_tile: HexTile = null
var drag_offset: Vector2 = Vector2.ZERO
var game_finished: bool = false
var drag_source_slot: BoardSlot = null

@onready var ui = $UI
@onready var background = $Background
@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer
@onready var ui_player = $UIPlayer

func _ready() -> void:
	background.modulate = Color(1, 1, 1, 0.6)
	
	ui.next_level_pressed.connect(_on_next_level)
	ui.reset_pressed.connect(_on_reset)
	$TitleScreen.start_pressed.connect(_on_game_start)
	
	music_player.stream = MUSIC
	music_player.volume_db = -13.0
	music_player.autoplay = false
	sfx_player.volume_db = -3.0
	ui_player.volume_db = -3.0
	
	_show_title()
	_play_music()

func _play_music() -> void:
	if not music_player.playing:
		music_player.play()

func _play_sfx(stream: AudioStream) -> void:
	sfx_player.stream = stream
	sfx_player.play()

func _play_ui(stream: AudioStream) -> void:
	ui_player.stream = stream
	ui_player.play()

func _show_title() -> void:
	$TitleScreen.visible = true
	ui.visible = false
	for child in get_children():
		if child is HexTile or child is BoardSlot:
			child.queue_free()

func _on_game_start() -> void:
	_play_ui(SFX_CLICK)
	game_finished = false
	current_level_index = 0
	$TitleScreen.visible = false
	ui.visible = true
	_load_level(0)

func _load_level(index: int) -> void:
	for child in get_children():
		if child is HexTile or child is BoardSlot:
			child.queue_free()
	ui.hide_win()
	
	if index < LEVEL_BACKGROUNDS.size():
		background.texture = LEVEL_BACKGROUNDS[index]
		
	if index >= LEVELS.size():
		ui.show_win("Gotovo!", "Pritisnite dugme da se vratite na pocetak.", true)
		return
	
	current_level = LevelLoader.load_level(LEVELS[index])
	if current_level.is_empty():
		push_error("Level nije ucitan.")
		return
	
	ui.set_level_label(current_level.get("molecule", ""))
	ui.set_counter(index + 1, LEVELS.size())
	_spawn_slots()
	_spawn_tiles()

func _spawn_slots() -> void:
	for slot_data in current_level.get("slots", []):
		var slot: BoardSlot = BoardSlotSCN.instantiate()
		add_child(slot)
		slot.global_position = Vector2(slot_data.x, slot_data.y)

func _spawn_tiles() -> void:
	var pool_data: Array = current_level.get("pool", [])
	pool_data.shuffle()
	var center_x: float = get_viewport_rect().size.x / 2.0
	var pool_y: float = 850.0
	var spacing: float = 140.0
	for i in pool_data.size():
		var tile: HexTile = HexTileSCN.instantiate()
		add_child(tile)
		var offset := (i - (pool_data.size() - 1) / 2.0) * spacing
		var pos := Vector2(center_x + offset, pool_y)
		tile.global_position = pos
		tile.home_pos = pos
		tile.setup(pool_data[i].element, pool_data[i].edges)
		tile.tile_clicked.connect(_on_tile_clicked)

func _on_next_level() -> void:
	_play_ui(SFX_CLICK)
	if game_finished:
		game_finished = false
		ui.visible = false
		ui.hide_win()
		current_level_index = 0
		for child in get_children():
			if child is HexTile or child is BoardSlot:
				child.queue_free()
		$TitleScreen.visible = true
	elif current_level_index >= LEVELS.size() - 1:
		game_finished = true
		ui.show_win("Gotovo!", "Prosli ste sve nivoe. Pritisnite za pocetak.", true)
	else:
		current_level_index += 1
		_load_level(current_level_index)
func _on_tile_clicked(tile: HexTile) -> void:
	_play_sfx(SFX_PICKUP)
	drag_source_slot = null
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.occupied_by == tile:
			drag_source_slot = slot  # ← zapamti odakle dolazi
			slot.occupied_by = null
			slot.highlight(false)
	dragged_tile = tile
	drag_offset = get_global_mouse_position() - tile.global_position
	move_child(tile, get_child_count() - 1)
	
		
func _process(_delta: float) -> void:
	if dragged_tile == null:
		return
	dragged_tile.global_position = get_global_mouse_position() - drag_offset
	var nearest := _find_nearest_slot_any(get_global_mouse_position())
	for slot in get_tree().get_nodes_in_group("slots"):
		slot.highlight(slot == nearest)
		
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_on_reset()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragged_tile == null:
			return
		var mouse_pos := get_global_mouse_position()
		var nearest_slot := _find_nearest_slot_any(mouse_pos)
		
		if nearest_slot == null:
			# Nije blizu nijednog slota — vrati u home_pos
			dragged_tile.global_position = dragged_tile.home_pos
		elif nearest_slot.is_free():
			# Slobodan slot — samo postavi
			dragged_tile.global_position = nearest_slot.global_position
			nearest_slot.occupied_by = dragged_tile
			nearest_slot.highlight(false)
			_play_sfx(SFX_SNAP)
		else:
			# Slot zauzet — swap
			var other_tile: HexTile = nearest_slot.occupied_by
			# Pronadji da li dragged_tile dolazi sa nekog slota
			var source_slot: BoardSlot = null
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.occupied_by == dragged_tile:
					source_slot = slot
					break
			
			if drag_source_slot != null:
				# Swap izmedju dva slota
				drag_source_slot.occupied_by = other_tile
				other_tile.global_position = drag_source_slot.global_position
			else:
				# Dolazi iz pool-a
				other_tile.global_position = other_tile.home_pos
			nearest_slot.occupied_by = dragged_tile
			dragged_tile.global_position = nearest_slot.global_position
			nearest_slot.highlight(false)
			_play_sfx(SFX_SNAP)
		
		# Reset highlight-a svih slotova
		for slot in get_tree().get_nodes_in_group("slots"):
			slot.highlight(false)
		
		dragged_tile = null
		_check_win()
func _find_nearest_slot_any(pos: Vector2) -> BoardSlot:
	var nearest: BoardSlot = null
	var nearest_dist: float = BoardSlot.SNAP_DISTANCE
	for slot in get_tree().get_nodes_in_group("slots"):
		var dist := pos.distance_to(slot.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = slot
	return nearest
	
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
		_play_sfx(SFX_WIN)
		ui.show_win(current_level.get("molecule", ""), current_level.get("hint", ""))
	else:
		_play_sfx(SFX_ERROR)

func _validate_edges(slots: Array) -> bool:
	const NEIGHBOR_DIST: float = 150.0
	
	# Uslov 1: susedni slotovi moraju imati poklapajuce edge vrednosti
	for i in slots.size():
		var slot_a: BoardSlot = slots[i]
		var tile_a: HexTile = slot_a.occupied_by
		for j in slots.size():
			if i == j: continue
			var slot_b: BoardSlot = slots[j]
			var tile_b: HexTile = slot_b.occupied_by
			if slot_a.global_position.distance_to(slot_b.global_position) > NEIGHBOR_DIST: continue
			var edge_idx := _get_edge_index(slot_a.global_position, slot_b.global_position)
			var val_a: int = tile_a.edges[edge_idx]
			var val_b: int = tile_b.edges[(edge_idx + 3) % 6]
			if val_a != val_b: return false
	
	# Uslov 2: svaki non-zero edge mora imati suseda u tom pravcu
	for i in slots.size():
		var slot_a: BoardSlot = slots[i]
		var tile_a: HexTile = slot_a.occupied_by
		for edge_i in 6:
			if tile_a.edges[edge_i] == 0: continue
			var has_neighbor: bool = false
			for j in slots.size():
				if i == j: continue
				var slot_b: BoardSlot = slots[j]
				if slot_a.global_position.distance_to(slot_b.global_position) > NEIGHBOR_DIST: continue
				if _get_edge_index(slot_a.global_position, slot_b.global_position) == edge_i:
					has_neighbor = true
					break
			if not has_neighbor: return false
	
	return true

func _get_edge_index(from: Vector2, to: Vector2) -> int:
	var dir := (to - from).normalized()
	var best_idx := 0
	var best_dot := -2.0
	for i in 6:
		var dot := dir.dot(Vector2(cos(deg_to_rad(30.0+60.0*i)), sin(deg_to_rad(30.0+60.0*i))))
		if dot > best_dot:
			best_dot = dot
			best_idx = i
	return best_idx

func _on_reset() -> void:
	_play_ui(SFX_CLICK)
	_load_level(current_level_index)

func _on_back() -> void:
	_play_ui(SFX_CLICK)
	game_finished = false
	current_level_index = 0
	ui.visible = false
	ui.hide_win()
	for child in get_children():
		if child is HexTile or child is BoardSlot:
			child.queue_free()
	$TitleScreen.visible = true
