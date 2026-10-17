extends Node
const FILE_POPUP = preload("uid://j322c0mbxv58")
const FOLDER_POPUP = preload("uid://bhrxyglvvdsj4")
const FILE = preload("uid://buph0h50ickkm")

enum fileStates {IDLE, CLICKED, DRAGGING, DROPPED}
var filesInFolder := []

func add_file(file: File):
	filesInFolder.append(file.duplicate())
	print("added file to folder", filesInFolder)

func open_file_popup(file: File):
	var popup := FILE_POPUP.instantiate()
	var desktop := get_tree().get_first_node_in_group("desktop")
	desktop.add_child(popup)
	popup.visible = true
	var label: Label = popup.get_child(0).get_child(0)
	label.text = file.fileContent.content
	
	# live-update while popup is open
	var on_changed := func(text: String): label.text = text
	file.fileContent.changed_content.connect(on_changed)
	
	# disconnect when popup closes
	popup.tree_exiting.connect(func():
		if file.fileContent.changed_content.is_connected(on_changed):
			file.fileContent.changed_content.disconnect(on_changed)
	)

func open_folder(folder: Folder) -> void:
	var popup := FOLDER_POPUP.instantiate()
	var desktop := get_tree().get_first_node_in_group("desktop")
	desktop.add_child(popup)

	var container: Container = popup.find_child("Container", true, false)

	for template : File in filesInFolder:
		var file: File = template.duplicate() # fresh copy 4 each open
		file.inFolder = true
		file.currState = Globalz.fileStates.IDLE
		file.fileOverFolder = false
		container.add_child(file)
