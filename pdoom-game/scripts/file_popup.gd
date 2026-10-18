class_name FilePopup
extends ColorRect
@export var folder := false
@export var fileRef : String

func _ready() -> void:
	# make userChoiceBtns container and array ref.s ready for access
	if not folder and fileRef == "chat.txt":
		Globalz.userChoiceBtnsContainer = find_child("Buttons", true, false)
		Globalz.userChoiceBtns = Globalz.userChoiceBtnsContainer.get_children()
		for i in Globalz.userChoiceBtns.size():
			Globalz.userChoiceBtns[i].pressed.connect(func(): Globalz.choice_resolved.emit(i))
		Globalz.popup_opened.emit()
	position += Vector2(randf_range(-50, 50), randf_range(-50, 50)) # slightly randomized filepopup

func _exit_tree() -> void:
	if not folder: Globalz.choice_resolved.emit(-1)

func _on_popup_close_button_pressed() -> void:
	queue_free()

func close_popup():
	# disconnect signal and remove from openFiles when popup closes
	print("here")
	Globalz.openFiles.erase(fileRef)

func _on_user_choice_button_pressed() -> void:
	print("pressing user chocieeeeee")
	Globalz.user_chose.emit(0)

#func _on_folder_popup_area_mouse_entered() -> void:
	#print("MOUSE INSIDE FOLDER")
	#Globalz.mouseOverFolderPopupArea = true
#
#func _on_folder_popup_area_mouse_exited() -> void:
	#print("MOUSE OUTSIDE FOLDER")
	#Globalz.mouseOverFolderPopupArea = false
