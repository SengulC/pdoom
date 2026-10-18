class_name File extends TextureButton

var mouseInArea := false
@export var currState := Globalz.fileStates.IDLE
var dragging := false
@export var fileOverFolder := false
@export var inFolder := false
@export var fileContent : FileContent
@export var fileCurrentlyOpen := false 
@export var fileRef := ""

var homeContainer # folder container inFolder

const DRAG_THRESHOLD := 4.0
var grab_offset := Vector2.ZERO
var press_pos := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("mouse_entered", _on_file_mouse_entered)
	self.connect("mouse_exited", _on_file_mouse_exited)
	$Label.text = fileRef

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currState == Globalz.fileStates.CLICKED:
		_clicked()
	if currState == Globalz.fileStates.DROPPED:
		print("dropped")
		_drop()

func _clicked():
	var mouse_pos = get_global_mouse_position()
	# only start dragging after the mouse actually moves past a threshold
	if not dragging and mouse_pos.distance_to(press_pos) > DRAG_THRESHOLD:
		dragging = true
		if inFolder and get_parent() is Container:
			homeContainer = get_parent()
			# takeout of folder container for dragging
			reparent(get_tree().get_first_node_in_group("desktop"), true)
	# keep the original grab point under the cursor, so no jump
	if dragging:
		global_position = mouse_pos - grab_offset

func _drop():
	inFolder = true
	Globalz.add_file(self)
	currState = Globalz.fileStates.IDLE
	queue_free()

func _open_file():
	Globalz.open_file_popup(self)
	fileCurrentlyOpen = true

func _return_to_folder() -> void:
	if is_instance_valid(homeContainer):
		reparent(homeContainer, false)
	#else:
		#_remove_from_folder()

func _remove_from_folder() -> void:
	Globalz.remove_file(fileRef)
	inFolder = false
	fileOverFolder = false
	homeContainer = null
	print("removed from folder: ", fileRef)

func _input(event: InputEvent):
	# mouse clicking on file should activate clicking state (which could lead to drag and drop or nothing at all)
	# and we also check/wait for double click
	if event.is_action_pressed("lmb_click") and mouseInArea:
		currState = Globalz.fileStates.CLICKED
		press_pos = get_global_mouse_position()
		grab_offset = press_pos - global_position
		dragging = false

		if event is InputEventMouseButton and event.double_click:
			_open_file()
			currState = Globalz.fileStates.IDLE  # to not start a drag on potential doubletap
	
	if event.is_action_released("lmb_click") and currState == Globalz.fileStates.CLICKED:
		# releasing when file is being hovered over folder should drop the file in that folder
		if fileOverFolder:
			currState = Globalz.fileStates.DROPPED
		elif inFolder and dragging:
			# if dragging file inFolder...
			# if overFolderArea, keep/return to folder
			if Globalz.is_mouse_over_folder_popup():
				_return_to_folder()
			# else, remove from folder!
			else:
				_remove_from_folder()
			currState = Globalz.fileStates.IDLE
			dragging = false
		# releasing else, reverts to idle, so nothing
		else:
			currState = Globalz.fileStates.IDLE
			dragging = false


func _on_file_mouse_entered() -> void:
	mouseInArea = true

func _on_file_mouse_exited() -> void:
	mouseInArea = false
