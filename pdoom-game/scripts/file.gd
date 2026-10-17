class_name File extends TextureButton

var mouseInArea := false
@export var currState := Globalz.fileStates.IDLE
var dragging := false
@export var fileOverFolder := false
@export var inFolder := false
@export var fileContent : FileContent

const DRAG_THRESHOLD := 4.0
var grab_offset := Vector2.ZERO
var press_pos := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("mouse_entered", _on_file_mouse_entered)
	self.connect("mouse_exited", _on_file_mouse_exited)

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

	# releasing when file is being hovered over folder should drop the file in that folder
	if event.is_action_released("lmb_click") and fileOverFolder:
		currState = Globalz.fileStates.DROPPED
	# releasing elseif, reverts to idle, so nothing
	elif event.is_action_released("lmb_click"):
		currState = Globalz.fileStates.IDLE
		dragging = false

func _on_file_mouse_entered() -> void:
	mouseInArea = true

func _on_file_mouse_exited() -> void:
	mouseInArea = false
