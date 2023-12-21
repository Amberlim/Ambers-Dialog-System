extends Panel

@export var file_name : NodePath
@export var cancel_button : NodePath
@export var confirm_button : NodePath
@export var back_button : NodePath
@export var error_message : Label

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
		
		var dialog = get_tree().compile_nodes_into_json()
		print(dialog)
		# Change window title
		Window.title = file_path
		
	else:
		error_message.show()

# Open a file
func _on_open_pressed():
	if file_path:
		if Global.file_exists(file_path):
			
			# Parse JSON to *dialog* dictionary in scene tree
			var file = FileAccess.open(Global.get_formal_filepath(file_path),FileAccess.READ)
			var dialog = JSON.parse_string(file.get_as_test())
			
			# Change window title
			Window.title = file_path
			
			# Emit signal
			get_tree().emit("open_file", dialog)
			
		else:
			error_message.show()

# Create a new file			
func _on_create_pressed():
	_on_save_pressed()
