extends Node2D
@onready var file_popup: ColorRect = $DesktopUIControl/FilePopup

func _on_popup_close_button_pressed() -> void:
	file_popup.visible = false
