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
	molecule_label.text = molecule
	hint_label.text = hint
	win_screen.visible = true

func hide_win() -> void:
	win_screen.visible = false

func _on_next_pressed() -> void:
	emit_signal("next_level_pressed")
