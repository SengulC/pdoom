class_name FilePopup
extends ColorRect
@export var folder := false
@export var fileRef : String

#func _ready() -> void:
	#tree_exiting.connect(close_popup)

func _on_popup_close_button_pressed() -> void:
	queue_free()

func close_popup():
	# disconnect signal and remove from openFiles when popup closes
	print("here")
	Globalz.openFiles.erase(fileRef)
