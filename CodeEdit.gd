extends CodeEdit

# Nodes
@onready var audio = $TypeSound

# Variables
var last_pitch = 1.0

func play_type_sounds():
	randomize()
	audio.pitch_scale = randf_range(0.9, 1.8)
	audio.volume_db = randf_range(-6, 0.2)
	
	while abs(audio.pitch_scale - last_pitch) < 0.1:
		randomize()
		audio.pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = audio.pitch_scale
	
	audio.play(0.0)

func _on_text_changed():
	play_type_sounds()


#func check():
#
#	var dialog_block = text.split("\n")
#
#	for text in dialog_block:
#
#		var chapter : String
#		var character_name : String
#		var character_mood : String
#
#		# 0 | Get chapter name
#		if "Chapter" in text:
#			chapter = text
#
#		# 1 | Get character name
#		if ":" in text:
#			character_name = text.get_slice(":", 0)
#
#			# 1.1 | Check if there is mood indicator
#			if "," in character_name:
#				character_mood = character_name.get_slice(",", 1)
#
#		# 2 | Check for 
#		if "{" in text:
#			if "wait" in text:
#				print("wait")
#			elif "stop" in text:
#				print("stop")
#			elif "var" in text:
#				print("var")
#			elif "heart" in text:
#				print("heart")
#			elif "emit" in text:
#				print("emit")
#			elif "if" in text:
#				print("if")
#
#		if "[" in text:
#			if "mood" in text:
#				pass
#			if "backdrop" in text:
#				pass
#		if "///" in text
