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
signal mg_won()

func _ready() -> void:
	overlay = get_tree().get_first_node_in_group("overlay")
	
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

func close_chat_file_popup():
	# for all popups
	var openPopups := get_tree().get_nodes_in_group("filePopup")
	for popup in openPopups:
		if popup.fileRef == "chat.txt":
			popup.queue_free()

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

# LEVEL/GAME MANAGEMENT------------------------------
const SECS_PER_CHAR := 0.05
const MIN_DELAY := 0.5
const START_DELAY := 2.5
var chatFile: File
var chatContent: FileContent
var overlay: ColorRect

func _get_cur_time() -> String:
	return "%s:%s:%s" %[Time.get_time_dict_from_system().hour, Time.get_time_dict_from_system().minute, Time.get_time_dict_from_system().second];

var mg_started := false
func setup_minigame():
	var mg :PipeGame = get_tree().get_first_node_in_group("gridGame")
	mg_started = true
	mg.process_mode = Node.PROCESS_MODE_ALWAYS
	mg.visible = true
	mg.activate_hud()
	
func unsetup_minigame():
	var mg :PipeGame= get_tree().get_first_node_in_group("gridGame")	
	mg.process_mode = Node.PROCESS_MODE_DISABLED
	mg.visible = false
	mg.deactivate_hud()
	mg.queue_free()

const ENDING = preload("uid://ckepih1bi7nk3")
func begin_phase() -> void:
	AudioManager.play_os("notif")
	for idx in Phases.phase01.size():
		var dict: Dictionary = Phases.phase01[idx]
		for speaker in dict:
			var line = dict[speaker]
			
			# make budget red. calc for current line
			var budgetReduction = Phases.phase01_budget_decr[idx]
			Globalz.currBudget += budgetReduction
			
			## RESET, terminate current chat, call reset on files NOT in folder
			if speaker == "RESET":
				system_reset()
				continue
			
			if speaker == "ending":
				get_tree().change_scene_to_packed(ENDING)
			
			if speaker == "minigame":
				print('minigame time')
				# set hacker exe as visible which pressing, setsupminigame
				var hackBtn := get_tree().get_first_node_in_group("hackExe")
				hackBtn.visible = true
				AudioManager.play_os("notif")
				print("set hackbtn visible awaiting")
				await Globalz.mg_won
				unsetup_minigame()
				hackBtn.visible = false
				continue
			
			## user choice presented, must wait until they make their choice!
			if speaker == "userChoice":
				var choice := -1
				while choice == -1:
					while not Globalz.is_choice_ui_ready():
						await Globalz.popup_opened

					for i in Globalz.userChoiceBtns.size():
						Globalz.userChoiceBtns[i].visible = true
						Globalz.userChoiceBtns[i].text = line[i]

					choice = await Globalz.choice_resolved

				for btn in Globalz.userChoiceBtns:
					if is_instance_valid(btn):
						btn.visible = false
				continue
				
			## user narration, must edit inner dialog textbox and keep continue
			if speaker == "me":
				print("speaker is me! innerrr")
				Globalz.inner_dialog.emit(line)
				continue

			## regular chat prog.
			chatContent.append("%s: %s - %s\n" % [_get_cur_time(), line, speaker])
			await get_tree().create_timer(maxf(MIN_DELAY, line.length() * SECS_PER_CHAR)).timeout
			
			# send signal out for actually changing budget after text has been sent/received
			Globalz.budget_reduced.emit(Globalz.currBudget)
			#print("sent out signal")

const RESTART_DELAY = 5.0
func system_reset():
	#overlay.
	# IF CHAT NOT INFOLDER: SET FILE AND POPUP INVISIBLE AND CLEAR CONTENT, THEN ON SOME TIMER RE-ACTIVATE
	if not chatFile.inFolder:
		chatFile.visible = false
		chatFile.fileContent.content = ""
		close_chat_file_popup()

	# REMOVE OTHER FILES IN DESKTOP
	var activeFiles := get_tree().get_nodes_in_group("file")
	for file:File in activeFiles:
		if file.fileRef != "chat.txt" and !file.inFolder:
			file.queue_free()
	
	pulse_params([5.0, 1.0])   # glitch_rate -> 5, glitch_intensity -> 1, then back
	fade_to_black(1.5)         # fade out
	await get_tree().create_timer(RESTART_DELAY).timeout
	chatFile.visible = true
	fade_to_black(0.5, 0.0)    # fade back in
	return

# SHADER FADE IN/OUT AND PULSE
var params := ["glitch_rate", "glitch_intensity"]
func _get_param(p: String) -> float:
	var v = overlay.material.get_shader_parameter(p)
	if v == null:
		var mat: ShaderMaterial = overlay.material
		v = RenderingServer.shader_get_parameter_default(mat.shader.get_rid(), p)
	return v if v != null else 0.0

func pulse_params(targets: Array, up_time := 0.2, down_time := 0.4) -> void:
	var originals := params.map(_get_param)
	var tween := create_tween()
	tween.tween_method(_apply.bind(originals, targets), 0.0, 1.0, up_time)
	tween.tween_method(_apply.bind(originals, targets), 1.0, 0.0, down_time)

func _apply(t: float, originals: Array, targets: Array) -> void:
	for i in params.size():
		overlay.material.set_shader_parameter(params[i], lerpf(originals[i], targets[i], t))

func fade_to_black(duration := 1.0, to := 1.0) -> void:
	var from := _get_param("darkness")
	create_tween().tween_method(
		func(v: float): overlay.material.set_shader_parameter("darkness", v),
		from, to, duration)
