extends Node

# audiostreamplayers
var active_ambience : AudioStreamPlayer
var active_music : AudioStreamPlayer
@onready var active_os: AudioStreamPlayer = $Clips/OneShotFX

# fade in/out tweens
var am_tween : Tween
var music_tween : Tween

# source fx/music files
@export var clips: Node
@export_group("Source")
@export var fx: Dictionary[String, AudioStream] = {}
@export var ambi_vol : float = 0.0
@export var music_vol : float = -10.0
@export_group("Music")
@export var ambiences : Dictionary[String, AudioStream] = {}
@export var music : Dictionary[String, AudioStream] = {}


# AUDIO SETTINGS
func set_master_volume(value: float) -> void:
	var index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(index, linear_to_db(value))

func set_music_volume(value: float) -> void:
	var index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear_to_db(value))

func set_sfx_volume(value: float) -> void:
	var index := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear_to_db(value))

func fade(c_tween:Tween, stream:AudioStreamPlayer, start_vol := 0.0, end_vol := 0.0, dur := 0.5, stop_on_end := false):
	if c_tween:
		c_tween.kill()
	c_tween = create_tween()
	stream.volume_db = start_vol
	c_tween.tween_property(stream, "volume_db", end_vol, dur)
	await c_tween.finished
	c_tween.stop()
	
	# if fading out
	if end_vol < start_vol and stop_on_end:
		stream.stop()
		#print("fading out: %s" % stream.stream.resource_path.get_file().get_basename())
	#else:
		#print("Fading in")
	return c_tween

func change_ambience(am_name: String) -> void:
	if active_ambience:
		if am_name == "null": 
			active_ambience.stop()
			return
		var c_am := active_ambience.stream.resource_path.get_file().get_basename()
		# if it's the same track, keep continue
		if c_am == am_name: return
		else: 
			#print("not the same am so changing TO %s from %s" %[am_name, c_am])
			am_tween = await fade(am_tween, active_ambience, ambi_vol, ambi_vol-20, 1.0, true) # fadeOUT current track b4 changing
			active_ambience = null
			play_ambience(am_name)

func play_ambience(am_name: String) -> void:
	if !active_ambience:
		active_ambience = clips.get_node("Ambience")
		active_ambience.stream = ambiences[am_name]
		#print("fading in %s" %am_name)
		am_tween = await fade(am_tween, active_ambience, ambi_vol-20, ambi_vol, 1.0) # fadeIN new track
		#print("calling play")
		active_ambience.play()

func change_music(song: String) -> void:
	if active_music:
		var c_song := active_music.stream.resource_path.get_file().get_basename()
		# if it's the same track, keep continue
		#print(c_song.get_basename())
		if c_song == song: return
		else: 
			music_tween = await fade(music_tween, active_music, music_vol, music_vol-20, 1.0, true) # fadeOUT current track b4 changing
			active_music = null
			play_music(song)

func play_music(song: String) -> void:
	if !active_music:
		active_music = clips.get_node("Music")
		active_music.stream = music[song]
		music_tween = await fade(music_tween, active_music, music_vol-20, music_vol, 1.0) # fadeIN new track
		active_music.play()

func increase_music_vol(amount: float = 8.0, dur: float = 1.5):
	if music_tween:
		music_tween = await fade(music_tween, active_music, active_music.volume_db, active_music.volume_db + amount, dur)
	else: 
		music_tween = create_tween()

func decrease_music_vol(amount: float = 15.0, dur: float = 1.5):
	if music_tween:
		music_tween = await fade(music_tween, active_music, active_music.volume_db, active_music.volume_db - amount, dur)
	else: 
		music_tween = create_tween()
	
# one shot - only played once no loop
func play_os(os_name: String, from: float = 0.0) -> void:
	if !active_os:
		active_os = clips.get_node("OneShotFX")
	if !fx.has(os_name):
		print("fx key not found: " + os_name)
		return
	active_os.stream = fx[os_name]
	active_os.volume_db = -40.0
	active_os.play(from)
