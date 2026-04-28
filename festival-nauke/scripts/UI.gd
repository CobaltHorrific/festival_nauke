extends CanvasLayer

@onready var win_screen = $WinScreen
@onready var molecule_label = $WinScreen/MoleculeLabel
@onready var hint_label = $WinScreen/HintLabel
@onready var next_button = $WinScreen/NextButton
@onready var reset_button = $ResetButton
@onready var level_label = $LevelLabel

signal next_level_pressed
signal reset_pressed

func _ready() -> void:
	win_screen.visible = false
	next_button.pressed.connect(_on_next_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	var vp := get_viewport().get_visible_rect().size
	reset_button.position = Vector2(20, vp.y - 120)
	reset_button.size = Vector2(120, 40)
	level_label.position = Vector2(vp.x / 2.0 - 150, 30)
	level_label.size = Vector2(300, 50)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func show_win(molecule: String, hint: String) -> void:
	var vp := get_viewport().get_visible_rect().size
	win_screen.position = Vector2.ZERO
	win_screen.size = vp
	molecule_label.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 - 80)
	hint_label.position = Vector2(vp.x / 2.0 - 300, vp.y / 2.0 - 10)
	next_button.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 + 80)
	molecule_label.text = molecule
	hint_label.text = hint
	win_screen.visible = true
	reset_button.visible = false

func hide_win() -> void:
	win_screen.visible = false
	reset_button.visible = true

func set_level_label(molecule: String) -> void:
	level_label.text = "Složi: " + molecule

func _on_next_pressed() -> void:
	emit_signal("next_level_pressed")

func _on_reset_pressed() -> void:
	emit_signal("reset_pressed")
