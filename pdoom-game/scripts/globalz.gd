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
var mouseOverFolderPopupArea = false

# SIGNAL BUS
signal user_chose(index: int) # for user choice in chat progression
signal popup_opened
signal budget_reduced(amount: int)
signal inner_dialog(words: String)
signal choice_resolved(index: int)   # -1 = popup closed without a choice

func is_choice_ui_ready() -> bool:
	return is_instance_valid(userChoiceBtnsContainer) and userChoiceBtnsContainer.is_inside_tree()

func add_file(file: File):
	filesInFolder.append(file.duplicate())
	print("added file to folder", filesInFolder)
	
	# folder alrdy open: call for resync
	if get_tree().get_first_node_in_group("folderPopup"):
		open_folder()

func remove_file(ref: String) -> void:
	for i in range(filesInFolder.size() - 1, -1, -1):
		if filesInFolder[i].fileRef == ref:
			filesInFolder[i].free()
			filesInFolder.remove_at(i)

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

var folderPopupArea: Area2D

func is_mouse_over_folder_popup() -> bool:
	if not is_instance_valid(folderPopupArea):
		return false
	var col: CollisionShape2D = folderPopupArea.find_child("CollisionShape2D", true, false)
	var rect_shape := col.shape as RectangleShape2D
	if rect_shape == null:
		return false
	# convert mouse into the collision shape's local space, then test against the shape's extents
	var local_mouse := col.to_local(col.get_global_mouse_position())
	var half := rect_shape.size / 2.0
	return Rect2(-half, rect_shape.size).has_point(local_mouse)

func open_folder() -> void:
	var existing := get_tree().get_first_node_in_group("folderPopup")
	if existing:
		# alrdy open: just sync its contents with filesInFolder
		_refresh_folder_contents(existing.find_child("Container", true, false))
		return

	var popup := FOLDER_POPUP.instantiate()
	var desktop := get_tree().get_first_node_in_group("desktop")
	desktop.add_child(popup)
	folderPopupArea = popup.find_child("FolderPopupArea2D", true, false)

	_refresh_folder_contents(popup.find_child("Container", true, false))

func _refresh_folder_contents(container: Container) -> void:
	# files currently displayed
	var shown := {}
	for child in container.get_children():
		if child is File:
			shown[child.fileRef] = child

	# adding files in filesInFolder but not yet displayed
	var wanted := {}
	for template: File in filesInFolder:
		wanted[template.fileRef] = true
		if not shown.has(template.fileRef):
			var file: File = template.duplicate()
			file.inFolder = true
			file.currState = fileStates.IDLE
			file.fileOverFolder = false
			container.add_child(file)

	# remove displayed files that are no longer in filesInFolder
	for ref in shown:
		if not wanted.has(ref):
			shown[ref].queue_free()
