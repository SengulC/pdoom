class_name File extends TextureButton

var mouseInArea := false
@export var currState := Globalz.fileStates.IDLE
@export var fileOverFolder := false
@export var inFolder := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("mouse_entered", _on_file_mouse_entered)
	self.connect("mouse_exited", _on_file_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if currState == Globalz.fileStates.DRAGGING:
		_drag()
	if currState == Globalz.fileStates.DROPPED:
		print("dropped")
		_drop()

func _drag():
	#print("dragging")
	if Input.get_last_mouse_velocity().abs() > Vector2.ZERO:
		var currentMousePos = get_global_mouse_position()
		var offsetVector = Vector2((size.x*scale.x)/pivot_offset_ratio.x, 0)
		var finalFilePos = currentMousePos - offsetVector
		position = finalFilePos

func _drop():
	inFolder = true
	Globalz.add_file(self)
	currState = Globalz.fileStates.IDLE
	queue_free()

func _input(event):
	# if user's mouse is in area of file, has clicked, and the mouse is in motion
	if event.is_action_pressed("lmb_click") and mouseInArea:
		currState = Globalz.fileStates.DRAGGING
	if event.is_action_released("lmb_click") and fileOverFolder:
		currState = Globalz.fileStates.DROPPED
	elif event.is_action_released("lmb_click"):
		currState = Globalz.fileStates.IDLE
	pass

func _on_file_mouse_entered() -> void:
	mouseInArea = true

func _on_file_mouse_exited() -> void:
	mouseInArea = false
