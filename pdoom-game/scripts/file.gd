class_name File extends TextureButton

var mouseInArea := false
@export var currState := Globalz.fileStates.IDLE
@export var fileOverFolder := false
@export var inFolder := false
@export var fileContent : FileContent

# src: https://godotforums.org/d/35106-is-there-a-simple-solution-for-a-double-tap/8
const DOUBLETAP_DELAY = .05
var doubletap_time = DOUBLETAP_DELAY
var last_keycode := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("mouse_entered", _on_file_mouse_entered)
	self.connect("mouse_exited", _on_file_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	doubletap_time = clamp(doubletap_time-delta, 0, doubletap_time)
	if currState == Globalz.fileStates.CLICKED:
		_clicked()
	if currState == Globalz.fileStates.DROPPED:
		print("dropped")
		_drop()
	#print(doubletap_time)

func _clicked():
	# dragging if mouse velocity is de/increasing
	if Input.get_last_mouse_velocity().abs() > Vector2.ZERO:
		var currentMousePos = get_global_mouse_position()
		var offsetVector = Vector2((size.x*scale.x)/pivot_offset_ratio.x, 0)
		var finalFilePos = currentMousePos - offsetVector
		position = finalFilePos
	#print(doubletap_time)

func _drop():
	inFolder = true
	Globalz.add_file(self)
	currState = Globalz.fileStates.IDLE
	queue_free()

func _input(event: InputEvent):
	# mouse clicking on file should activate clicking state (which could lead to drag and drop or nothing at all)
	# and we also check/wait for double click
	if event.is_action_pressed("lmb_click") and mouseInArea:
		currState = Globalz.fileStates.CLICKED
		doubletap_time = DOUBLETAP_DELAY
		#print("clicked once")
		if last_keycode == event.as_text() and doubletap_time >= 0: 
			#print("DOUBLETAP: ", event.as_text())
			Globalz.populate_file_popup(self)
			last_keycode = ""
		else: last_keycode = event.as_text()

	# releasing when file is being hovered over folder should drop the file in that folder
	if event.is_action_released("lmb_click") and fileOverFolder:
		currState = Globalz.fileStates.DROPPED
	# releasing elseif, reverts to idle, so nothing
	elif event.is_action_released("lmb_click"):
		currState = Globalz.fileStates.IDLE

func _on_file_mouse_entered() -> void:
	mouseInArea = true

func _on_file_mouse_exited() -> void:
	mouseInArea = false
