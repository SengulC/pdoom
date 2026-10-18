extends Node2D

const SECS_PER_CHAR := 0.05
const MIN_DELAY := 0.5
const START_DELAY := 2.5

var chatFile: File
var chatContent: FileContent
@onready var folder: Folder = $DesktopUIControl/FileContainer/Folder

func _ready() -> void:
	AudioManager.play_music("ambient")
	AudioManager.play_ambience("ambient")
	chatFile = get_tree().get_first_node_in_group("chatFile")
	chatContent = chatFile.fileContent  # survives file/popup nodes being freed..
	
	# wait for user/player to read instructions etc files then activate chatFile
	await get_tree().create_timer(START_DELAY).timeout
	chatFile.visible = true
	folder.visible = true
	Globalz.begin_phase()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lmb_click"):
		AudioManager.play_os("click")

func _on_hack_pressed() -> void:
	Globalz.setup_minigame()
