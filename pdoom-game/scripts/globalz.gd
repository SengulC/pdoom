extends Node

enum fileStates {IDLE, CLICKED, DRAGGING, DROPPED}
var filesInFolder := []

func add_file(file: File):
	filesInFolder.append(file.duplicate())
	print("added file to folder", filesInFolder)

func populate_file_popup(file: File):
	var popup := get_tree().get_first_node_in_group("filePopup")
	popup.visible = true
	var label: Label = popup.get_child(0).get_child(0)
	label.text = file.fileContent.content
