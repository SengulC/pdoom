extends ColorRect
@export var folder := false

func _on_popup_close_button_pressed() -> void:
	visible = false

#func _process(_delta):
	#print(get_children(true))
