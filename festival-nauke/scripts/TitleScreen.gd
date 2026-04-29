extends CanvasLayer

signal start_pressed

func _ready() -> void:
	var vp := get_viewport().get_visible_rect().size
	
	$Background.position = Vector2.ZERO
	$Background.size = vp
	$Background.texture = load("res://assets/sprites/background_main.png")
	$Background.modulate = Color(1, 1, 1, 0.85)
	
	$Logo.position = Vector2(vp.x / 2.0 - 425, vp.y / 2.0 - 250)
	$Logo.size = Vector2(900, 225)
	
	$StartButton.position = Vector2(vp.x / 2.0 - 150, vp.y / 2.0 + 20)
	$StartButton.size = Vector2(450, 150)
	$StartButton.position = Vector2(vp.x / 2.0 - 225, vp.y / 2.0 + 20)
	$StartButton.pressed.connect(_on_start_pressed)
	$StartButton.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	$StartButton.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	$StartButton.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	$StartButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _on_start_pressed() -> void:
	emit_signal("start_pressed")
