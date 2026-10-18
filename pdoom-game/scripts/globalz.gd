extends Node
const FILE_POPUP = preload("uid://j322c0mbxv58")
const FOLDER_POPUP = preload("uid://bhrxyglvvdsj4")
const FILE = preload("uid://buph0h50ickkm")

enum fileStates {IDLE, CLICKED, DRAGGING, DROPPED}
var filesInFolder := []
var openFiles := []
var userChoiceBtns
var userChoiceBtnsContainer

var currBudget := 1000
var budgetRef

# SIGNAL BUS
signal user_chose(index: int) # for user choice in chat progression
signal popup_opened
signal budget_reduced(amount: int)
signal inner_dialog(words: String)
#signal hide_inner()
signal choice_resolved(index: int)   # -1 = popup closed without a choice

func is_choice_ui_ready() -> bool:
	return is_instance_valid(userChoiceBtnsContainer) and userChoiceBtnsContainer.is_inside_tree()

func add_file(file: File):
	filesInFolder.append(file.duplicate())
	print("added file to folder", filesInFolder)

func open_file_popup(file: File):
	var fileRef = file.fileRef
	if fileRef in openFiles:
		print("file alrdy open exiting early")
		return

	openFiles.append(fileRef)

	var content: FileContent = file.fileContent
	var popup := FILE_POPUP.instantiate()
	popup.fileRef = fileRef
	var desktop := get_tree().get_first_node_in_group("desktop")
	desktop.add_child(popup)
	popup.visible = true

	var label: RichTextLabel = popup.find_child("Label", true, false)
	label.text = content.content

	var on_changed := func(text: String): label.text = text
	content.changed_content.connect(on_changed)

	popup.tree_exiting.connect(func():
		print("popup closed")
		if content.changed_content.is_connected(on_changed):
			content.changed_content.disconnect(on_changed)
		openFiles.erase(fileRef)
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
