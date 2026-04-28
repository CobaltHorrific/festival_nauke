extends CanvasLayer

@onready var background = $Background
@onready var title_label = $TitleLabel
@onready var subtitle_label = $SubtitleLabel
@onready var start_button = $StartButton

signal start_pressed

func _ready() -> void:
	var vp := get_viewport().get_visible_rect().size
	
	background.position = Vector2.ZERO
	background.size = vp
	background.color = Color("#0a1929")
	
	title_label.text = "SPOJI MOLEKUL"
	title_label.position = Vector2(vp.x / 2.0 - 300, vp.y / 2.0 - 150)
	title_label.size = Vector2(600, 100)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color("#4dd0e1"))
	
	subtitle_label.text = "Festival Nauke 2026"
	subtitle_label.position = Vector2(vp.x / 2.0 - 200, vp.y / 2.0 - 50)
	subtitle_label.size = Vector2(400, 50)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 28)
	subtitle_label.add_theme_color_override("font_color", Color("#f0f9ff"))
	
	start_button.text = "IGRAJ →"
	start_button.position = Vector2(vp.x / 2.0 - 100, vp.y / 2.0 + 50)
	start_button.size = Vector2(200, 60)
	start_button.add_theme_font_size_override("font_size", 28)
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	emit_signal("start_pressed")
