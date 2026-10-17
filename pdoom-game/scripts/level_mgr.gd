extends Node2D

const SECS_PER_CHAR := 0.05
const MIN_DELAY := 0.5

var chatFile: File
var chatContent: FileContent

func _ready() -> void:
	chatFile = get_tree().get_first_node_in_group("chatFile")
	chatContent = chatFile.fileContent  # survives file/popup nodes being freed..
	begin_phase_01()

func _get_cur_time() -> String:
	return "%s:%s:%s" %[Time.get_time_dict_from_system().hour, Time.get_time_dict_from_system().minute, Time.get_time_dict_from_system().second];

func begin_phase_01() -> void:
	for dict in Phases.phase01:
		for speaker in dict:
			var line = dict[speaker]
			print(speaker)
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
			
			## regular chat prog.
			chatContent.append("%s: %s - %s\n" % [_get_cur_time(), line, speaker]) #TODO: TOFIX
			await get_tree().create_timer(maxf(MIN_DELAY, line.length() * SECS_PER_CHAR)).timeout
			#await get_tree().create_timer(MIN_DELAY).timeout
