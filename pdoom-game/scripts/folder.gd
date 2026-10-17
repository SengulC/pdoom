extends TextureRect
@onready var area_2d: Area2D = $Area2D

func _on_folder_area_entered(area: Area2D) -> void:
	#if area.get_parent().currState == Globalz.fileStates.DRAGGING:
	print("file hovering over folder %s" %area.get_parent().name)
	var file : File = area.get_parent()
	file.fileOverFolder = true

func _on_folder_area_exited(area: Area2D) -> void:
	var file : File = area.get_parent()
	file.fileOverFolder = false
