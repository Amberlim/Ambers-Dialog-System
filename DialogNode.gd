extends Node2D

# Nodes
@export var text_edit : CodeEdit
@export var audio_stream : AudioStreamPlayer
@export var navigation : VBoxContainer
@export var anim : AnimationPlayer

# Elements
var dialog_block = []
var last_pitch = 1.0

func _ready():
	
	var highlighter = text_edit.syntax_highlighter
	
	var yellow_words = ["true", "false"]
	var pink_words = ["wait", "terminate", "if", "else if", "or else", "no more what ifs"]
	var purple_words = ["is behind us"]
	var blue_words = ["Chapter"]
	
	var yellow_color = Color(0.78823530673981, 0.61960786581039, 0)
	var green_color = Color(0.36862745881081, 0.81568628549576, 0)
	var pink_color = Color(0.85098040103912, 0.40392157435417, 0.91764706373215)
	var purple_color = Color(0.56078433990479, 0.15686275064945, 1)
	var blue_color = Color(0, 0.42745098471642, 1)
	
	for word in yellow_words:
		highlighter.add_keyword_color(word, yellow_color)
	for word in pink_words:
		highlighter.add_keyword_color(word, pink_color)
	for word in purple_words:
		highlighter.add_keyword_color(word, purple_color)
	for word in blue_words:
		highlighter.add_keyword_color(word, blue_color)
		
	highlighter.add_color_region("%", " ", green_color)
	highlighter.add_color_region("$", " ", green_color)

func check():
	
	dialog_block = text_edit.text.split("\n")
	
	for text in dialog_block:
		
		var chapter : String
		var character_name : String
		var character_mood : String
		
		# 0 | Get chapter name
		if "Chapter" in text:
			chapter = text
			
		# 1 | Get character name
		if ":" in text:
			character_name = text.get_slice(":", 0)
			
			# 1.1 | Check if there is mood indicator
			if "," in character_name:
				character_mood = character_name.get_slice(",", 1)
			
		# 2 | Check for 
		if "{" in text:
			if "wait" in text:
				print("wait")
			elif "stop" in text:
				print("stop")
			elif "var" in text:
				print("var")
			elif "heart" in text:
				print("heart")
			elif "emit" in text:
				print("emit")
			elif "if" in text:
				print("if")

		if "[" in text:
			if "mood" in text:
				pass
			if "backdrop" in text:
				pass
#		if "///" in text




func play_type_sounds():
	randomize()
	audio_stream.pitch_scale = randf_range(0.9, 1.8)
	audio_stream.volume_db = randf_range(-6, 0.2)
	
	while abs(audio_stream.pitch_scale - last_pitch) < 0.1:
		randomize()
		audio_stream.pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = audio_stream.pitch_scale
	
	audio_stream.play(0.0)
	
func _on_text_edit_text_changed():
	play_type_sounds()

func _on_menu_toggled(button_pressed):
	navigation.visible = button_pressed
	if button_pressed:
		anim.play("MenuPeekOut")
	else:
		anim.play_backwards("MenuPeekOut")	


func _on_new_pressed():
	pass
	
func _on_open_pressed():
	pass # Replace with function body.

func _on_save_pressed():
	pass
