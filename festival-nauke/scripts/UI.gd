extends CanvasLayer

@onready var win_screen = $WinScreen
@onready var molecule_label = $WinScreen/MoleculeLabel
@onready var hint_label = $WinScreen/HintLabel
@onready var next_button = $WinScreen/NextButton

signal next_level_pressed

func _ready() -> void:
	win_screen.visible = false
	next_button.pressed.connect(_on_next_pressed)

func show_win(molecule: String, hint: String) -> void:
	# Postavi velicinu na ceo ekran direktno kroz kod
	var vp := get_viewport().get_visible_rect().size
	win_screen.position = Vector2.ZERO
	win_screen.size = vp
	molecule_label.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 - 80)
	hint_label.position = Vector2(vp.x / 2.0 - 300, vp.y / 2.0 - 10)
	next_button.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 + 80)
	molecule_label.text = molecule
	hint_label.text = hint
	win_screen.visible = true

func hide_win() -> void:
	win_screen.visible = false

func _on_next_pressed() -> void:
	emit_signal("next_level_pressed")
