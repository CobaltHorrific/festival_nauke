extends CanvasLayer

@onready var win_screen = $WinScreen
@onready var molecule_label = $WinScreen/MoleculeLabel
@onready var hint_label = $WinScreen/HintLabel
@onready var next_button = $WinScreen/NextButton
@onready var reset_button = $ResetButton
@onready var level_label = $LevelLabel
@onready var counter_label = $CounterLabel

signal next_level_pressed
signal reset_pressed

func _ready() -> void:
	win_screen.visible = false
	next_button.pressed.connect(_on_next_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	var vp := get_viewport().get_visible_rect().size
	reset_button.position = Vector2(0, vp.y - 170)
	reset_button.size = Vector2(300, 105)
	var restart_tex := load("res://assets/sprites/btn_restart.png")
	reset_button.icon = restart_tex
	reset_button.text = ""
	reset_button.expand_icon = true
	reset_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reset_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	reset_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	reset_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	
	var next_tex := load("res://assets/sprites/btn_next.png")
	next_button.icon = next_tex
	next_button.text = ""
	next_button.expand_icon = true
	next_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	next_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	next_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	
	level_label.position = Vector2(vp.x / 2.0 - 150, 30)
	level_label.size = Vector2(300, 50)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	counter_label.position = Vector2(vp.x - 150, 30)
	counter_label.size = Vector2(130, 50)
	counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func show_win(molecule: String, hint: String) -> void:
	var vp := get_viewport().get_visible_rect().size
	win_screen.position = Vector2.ZERO
	win_screen.size = vp
	molecule_label.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 - 80)
	hint_label.position = Vector2(vp.x / 2.0 - 300, vp.y / 2.0 - 10)
	next_button.position = Vector2(vp.x / 2.0 - 225, vp.y / 2.0 + 80)
	next_button.size = Vector2(450, 150)
	molecule_label.text = molecule
	hint_label.text = hint
	win_screen.visible = true
	reset_button.visible = false

func hide_win() -> void:
	win_screen.visible = false
	reset_button.visible = true

func set_level_label(molecule: String) -> void:
	level_label.text = "Slozi: " + molecule

func set_counter(current: int, total: int) -> void:
	counter_label.text = str(current) + "/" + str(total)

func _on_next_pressed() -> void:
	emit_signal("next_level_pressed")

func _on_reset_pressed() -> void:
	emit_signal("reset_pressed")
