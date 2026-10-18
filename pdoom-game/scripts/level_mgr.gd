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
	for idx in Phases.phase01.size():
		var dict: Dictionary = Phases.phase01[idx]
		for speaker in dict:
			var line = dict[speaker]
			
			# make budget red. calc for current line
			var budgetReduction = Phases.phase01_budget_decr[idx]
			Globalz.currBudget -= budgetReduction
			#print("we are on idx %s therefore reducing budget results in %s" %[idx, Globalz.currBudget])
			
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
			print("sent out signal")
