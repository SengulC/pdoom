extends Node2D

const SECS_PER_CHAR := 0.5
const MIN_DELAY := 0.8

var chatFile: File
var chatContent: FileContent

func _ready() -> void:
	var chatFile: File = get_tree().get_first_node_in_group("chatFile")
	chatContent = chatFile.fileContent  # survives file/popup nodes being freed..
	begin_phase_01()

func _get_cur_time() -> String:
	return "%s:%s:%s" %[Time.get_time_dict_from_system().hour, Time.get_time_dict_from_system().minute, Time.get_time_dict_from_system().second];

func begin_phase_01() -> void:
	for dict in Phases.phase01:
		for speaker in dict:
			#if speaker == "userChoice":
				## set two buttons as visible
				## populate their text
				## clicking on them -> toggles off Globalz.UserChose flag
				#while not Globalz.userChose:
					## WAIT
					#pass
				#continue
			var line: String = dict[speaker]
			chatContent.append("%s: %s - %s\n" % [_get_cur_time(), line, speaker]) #TODO: TOFIX
			await get_tree().create_timer(maxf(MIN_DELAY, line.length() * SECS_PER_CHAR)).timeout
			#await get_tree().create_timer(MIN_DELAY).timeout
