extends GraphEdit

# Signals
signal open_file(parsed_dialog)

# Get nodes
@onready var last_instanced_node = $Start

# Keep Count
var dialog_node_count = 0

# Data
var dialog = {}



################## Shortcut Keys ####################################
	
func _ready():
	Window.title = "Untitled.json"
	
func _input(event):
	if Input.is_action_pressed("New Node"):
		_on_new_node_pressed()
	elif Input.is_action_pressed("Return to Start"):
		scroll_offset = Vector2(-200, -40)
	elif Input.is_action_just_pressed("New Feature"):
		_on_new_feature_pressed()
	elif Input.is_action_pressed("Open"):
		$CanvasLayer/Panel/OpenFileDialog.show()
	elif Input.is_action_pressed("Save"):
		print(Window.title)
		if Global.if_file_exists(Window.title):
			$CanvasLayer/Panel/SaveFileDialog.show()

	
################## Creating a new node ####################################
func _on_new_node_pressed():
	var new_node = load("res://GraphNode.tscn")
	new_node = new_node.instantiate()
	add_child(new_node)
	
	dialog_node_count += 1
	new_node.title = "DIALOG_" + str(dialog_node_count)
	new_node.name = "DIALOG_" + str(dialog_node_count)
	new_node.node_data["node title"] = new_node.title
	
	new_node.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	last_instanced_node = new_node
	
	
	
	
################## Creating a new feature ####################################
func _on_new_feature_pressed():
	var new_feature = load("res://Feature.tscn")
	new_feature = new_feature.instantiate()
	add_child(new_feature)
	
	new_feature.title = "FEATURE_" + str(dialog_node_count)
	new_feature.name = "DIALOG_" + str(dialog_node_count)
	new_feature.node_data["node title"] = new_feature.title
	
	new_feature.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	last_instanced_node = new_feature
	
	
 
################## Ending the dialog ####################################
func _on_end_node_pressed():
	var end_node = load("res://End.tscn")
	end_node = end_node.instantiate()
	add_child(end_node)
	
	end_node.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	last_instanced_node = end_node




################## Open file ####################################
	
func _on_open_file(parsed_dialog):
	
	dialog = parsed_dialog
	
	# Assign nodes into/with correct positions and values
	
	# Nodes (incl. start & end nodes)
	# Features
	# Link connections 
	
################## Save a file ####################################

# Compile data to be saved
func compile_nodes_into_json():
	
	var existing_nodes = get_tree().get_nodes_in_group("nodes")
	
	for node in existing_nodes:
		node.update_data()
		
		dialog[node.node_data["node title"]] = {}
		var dialog_block = dialog[node.node_data["node title"]]
		dialog_block = node.node_data
		
		print(dialog_block)
	

################## Menu/Navigation ####################################

# Get nodes
@onready var menu_list = $CanvasLayer/Panel/MenuList
@onready var options_list = $CanvasLayer/Panel/Options
@onready var save_file_dialog = $CanvasLayer/Panel/SaveFileDialog
@onready var open_file_dialog = $CanvasLayer/Panel/OpenFileDialog
@onready var options_cancel_button = $CanvasLayer/Panel/CancelButton
@onready var options_panel = $CanvasLayer/Panel
@onready var back_button = $CanvasLayer/Panel/BackButton

# Data
var new_font_size = Global.font_size
var new_type_sound = Global.type_sound

func _on_menu_toggled(button_pressed):
	if button_pressed:
		options_panel.show()
	else:
		options_panel.hide()
	
func _on_cancel_button_pressed():
	options_panel.hide()

func _on_save_as_pressed():
	save_file_dialog.show()

func _on_open_pressed():
	open_file_dialog.show()

func _on_options_pressed():
	menu_list.hide()
	options_list.show()
	back_button.show()
	options_cancel_button.hide()

func _on_options_cancel_pressed():
	menu_list.show()
	options_list.hide()
	back_button.hide()
	options_cancel_button.show()

func _on_save_pressed():
	Global.font_size = new_font_size
	Global.type_sound = new_type_sound
	_on_options_cancel_pressed()

func _on_font_size_pressed(font_size):
	new_font_size = font_size

func _on_type_sound_pressed(index):
	new_type_sound = index
	
	


################## Connecting Nodes ####################################
func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)
	get_node(str(from_node)).node_data["go to"].append(to_node)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)
	get_node(str(from_node)).node_data["go to"].remove(to_node)
