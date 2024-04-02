extends Panel

@export var file_name : NodePath
@export var cancel_button : NodePath
@export var confirm_button : NodePath
@export var back_button : NodePath
@export var error_message : Label
@export var file_exists : Label
@export var jerk_anim : AnimationPlayer
@export var error_sound : AudioStreamPlayer
@export var notification_sound : AudioStreamPlayer

var confirm_file_overwrite = 0

var file_path 

# Cancel button
func _on_cancel_pressed():
	self.hide()

func _on_line_edit_text_changed(new_text):
	file_path = new_text
	error_message.hide()

# Save a file
func _on_save_pressed():
	if file_path and file_path.is_valid_filename():
		
		# If file exists
		if Global.if_file_exists(file_path) and confirm_file_overwrite == 0:
			confirm_file_overwrite += 1
			file_exists.show()
			
			#Animation Effects
			jerk_anim.play("Jerk")
			error_sound.play()
			
			return
			
		# Reset File exists error
		confirm_file_overwrite = 0
			
		# Get compiled data
		var dialog = get_tree().current_scene.compile_nodes_into_json()
	
		# Change window title
		DisplayServer.window_set_title(file_path)
		
		# Convert to Json
		dialog = JSON.stringify(dialog)
		
		# Save to file
		var file = FileAccess.open("user://" + file_path + ".json", FileAccess.WRITE)
		file.store_string(dialog)
		
		# Hide self
		self.hide()
		
		# Play notification sound
		if not notification_sound.playing:
			notification_sound.play()
		
	else:
		error_message.show()
		#Animation Effects
		$JerkAnimation.play("Jerk")
		$ErrorSound.play()

# Create a new file			
func _on_create_pressed():
	_on_save_pressed()

