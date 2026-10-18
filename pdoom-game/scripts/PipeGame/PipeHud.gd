extends CanvasLayer

signal undo_pressed
signal reset_pressed

@onready var label: Label = $MarginContainer/HBoxContainer/MovesLabel
@onready var status: Label = $MarginContainer/HBoxContainer/StatusLabel
@onready var undo_button: Button = $MarginContainer/HBoxContainer/UndoButton
@onready var reset_button: Button = $MarginContainer/HBoxContainer/ResetButton

func _ready() -> void:
	undo_button.text = "Undo"
	reset_button.text = "Reset"
	undo_button.pressed.connect(undo_pressed.emit)
	reset_button.pressed.connect(reset_pressed.emit)

func set_state(moves_left: int, can_undo: bool, won: bool) -> void:
	label.text = "Moves left: %d" % moves_left
	status.text = "Connected!" if won else ""
	undo_button.disabled = not can_undo
	reset_button.disabled = not can_undo
