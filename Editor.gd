extends GraphEdit

# Get nodes
@onready var last_instanced_node = $Start
@onready var saved_notification = $Tool/SavedNotification
@onready var spawn_sound = $SpawnSound
var rng = RandomNumberGenerator.new()


# Keep Count
var total_node_count = 0
var dialog_count = 0
var feature_count = 0
var option_count = 0
var end_count = 0


# Data
var dialog = {}

# Signals
signal graph_cleared



################## Shortcut Keys ####################################
	
func _input(event):
	if Input.is_action_pressed("New Node"):
		_on_new_node_pressed()
	elif Input.is_action_pressed("Return to Start"):
		scroll_offset = Vector2(-200, -40)
	elif Input.is_action_pressed("Go to End"):
		if has_node("End"):
			var end = $End
			var pos_x = end.position.x
			pos_x = pos_x * -1
			var pos_y = end.position.y
			pos_y = pos_y * -0.02
			scroll_offset = Vector2(pos_x, pos_y)
	elif Input.is_action_pressed("New File"):
		_on_new_pressed()
	elif Input.is_action_just_pressed("New Feature"):
		_on_new_feature_pressed()
	elif Input.is_action_pressed("Open"):
		$CanvasLayer/OpenFileDialog.show()
	elif Input.is_action_just_pressed("Save"):
		if Global.if_file_exists(get_window().title) == false:
			_on_save_as_pressed()
		else:
			save_file_dialog.file_path = get_window().title
			save_file_dialog._on_save_pressed()
			saved_notification.get_node("AnimationPlayer").play("FadeOut")


func random_number():
	return rng.randf_range(1, 1.5)
	
################## Creating a new node ####################################
func _on_new_node_pressed(open_save : bool = false):
	
	spawn_sound.pitch_scale = random_number()
	spawn_sound.play()
	
	var new_node = load("res://GraphNode.tscn")
	new_node = new_node.instantiate()
	
	update_node_count(1, 1)
	
	new_node.title = "DIALOG_" + str(dialog_count)
	new_node.name = "DIALOG_" + str(dialog_count)
	new_node.node_data["node title"] = new_node.name
	
	if not open_save:
		if last_instanced_node == null:
			last_instanced_node = $Start
		new_node.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	# Connect first dialog node to START
	auto_connect_start(new_node.name) 
	
	last_instanced_node = new_node
	
	add_child(new_node)
	
	
	
	
################## Creating a new feature ####################################
func _on_new_feature_pressed(open_save : bool = false):
	spawn_sound.pitch_scale = random_number()
	spawn_sound.play()
	
	var new_feature = load("res://Feature.tscn")
	new_feature = new_feature.instantiate()
	add_child(new_feature)
	
	update_node_count(1, 0, 1)
	
	new_feature.title = "FEATURE_" + str(feature_count)
	new_feature.name = "FEATURE_" + str(feature_count)
	new_feature.node_data["node title"] = new_feature.title
	
	if not open_save:
		if last_instanced_node == null:
			last_instanced_node = $Start
		new_feature.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	# Connect first dialog node to START
	auto_connect_start(new_feature.name) 
		
	last_instanced_node = new_feature
	
################## Creating a new option ####################################
func _on_new_option_pressed(open_save : bool = false):
	spawn_sound.pitch_scale = random_number()
	spawn_sound.play()
	
	var new_option = load("res://Option.tscn")
	new_option = new_option.instantiate()
	
	update_node_count(1,0,0,1)
	
	new_option.title = "OPTION_" + str(option_count)
	new_option.name = "OPTION_" + str(option_count)
	new_option.node_data["node title"] = new_option.name

	
	if not open_save:
		if last_instanced_node == null:
			last_instanced_node = $Start
		new_option.position_offset = last_instanced_node.position_offset + Vector2(350,10)
			
	# Connect first dialog node to START
	auto_connect_start(new_option.name) 
			
	last_instanced_node = new_option
	
	add_child(new_option)
 
################## Ending the dialog ####################################
func _on_end_node_pressed():
	if end_count == 0: 
		
		end_count += 1
		
		spawn_sound.pitch_scale = random_number()
		spawn_sound.play()
		
		var end_node = load("res://End.tscn")
		end_node = end_node.instantiate()
		add_child(end_node)
		
		end_node.position_offset = last_instanced_node.position_offset + Vector2(500,10)
		
		last_instanced_node = end_node




################## Open file ####################################
	
func _on_file_dialog_file_selected(path):
	
	# Clear all existing nodes
	clear_all()
	await self.graph_cleared
	
	# Hide Option Panel
	options_panel.hide()
	
	# Parse JSON to *dialog* dictionary in scene tree
	var file = FileAccess.open(path,FileAccess.READ)
	var dialog = JSON.parse_string(file.get_as_text())
	
	# Change window title
	get_window().title = path.get_file().replace(".json", "")
	
	# Assign nodes into/with correct positions and values
	# Nodes (incl. start & end nodes)
	for node in dialog:
		node = dialog[node]
		
		# if type: node
		if "DIALOG" in node["node title"]:
			_on_new_node_pressed(true)
			var current_node = get_node(node["node title"])

			current_node.position_offset.x = node["offset_x"]
			current_node.position_offset.y = node["offset_y"]
			
			current_node.text.text = node["text"]
		
			# match item string to item index
			for item in current_node.character.get_item_count():
					
				if current_node.character.get_item_text(item) == node["character"]:

					current_node.character.select(item)
					
					break
					
			current_node.line_asset.text = node["line asset"]
			
		# if type: feature	
		elif "FEATURE" in node["node title"]:
			_on_new_feature_pressed(true)
			var current_node = get_node(node["node title"])
			
			current_node.position_offset.x = node["offset_x"]
			current_node.position_offset.y = node["offset_y"]
			
			# variable
			if not node["variables"].is_empty():
				var variables_group = current_node.get_node("VariablesGroup")
				variables_group.show()
				
				for variable_set in node["variables"]:
					current_node._on_add_button_pressed("variable")
					
					var current_variable_count = current_node.variable_count
					var variable_node_name = "Variable" + str(current_variable_count)
					var variable_node = variables_group.get_node(variable_node_name)
					variable_node.text.text = node["variables"].keys()[current_variable_count - 1]
					variable_node.check_button.button_pressed = 	node["variables"].values()[current_variable_count - 1]
			
			# signals
			if not node["signals"].is_empty():
				var emit_signal_group = current_node.get_node("EmitSignalGroup")
				emit_signal_group.show()
				
				for single_signal in node["signals"]:
					current_node._on_add_button_pressed("signal")
					
					var current_signal_count = current_node.signal_count
					var signal_node_name = "Signal" + str(current_signal_count)
					var signal_node = emit_signal_group.get_node(signal_node_name)
					signal_node.text.text = node["signals"][current_signal_count - 1]
			
			# conditionals
			if not node["conditionals"].is_empty():

				var conditionals_group = current_node.get_node("ConditionalsGroup")
				conditionals_group.show()
				
				for conditional in node["conditionals"]:
					current_node._on_add_button_pressed("conditional")
					
					var current_conditional_count = current_node.conditional_count
					var conditional_node_name = "Conditional" + str(current_conditional_count)
					var conditional_node = conditionals_group.get_node(conditional_node_name)
					conditional_node.text.text = node["conditionals"].keys()[current_conditional_count - 1]
					conditional_node.check_button.button_pressed = node["conditionals"].values()[current_conditional_count - 1]
			
		# if type: option
		elif "OPTION" in node["node title"]:
			_on_new_option_pressed(true)
			var current_node = get_node(node["node title"])

			current_node.position_offset.x = node["offset_x"]
			current_node.position_offset.y = node["offset_y"]
			current_node.text.text = node["text"]
		
		# Link Connections
		if "End" in node["go to"]:
			_on_end_node_pressed()
			connect_node(node["node title"], 0, "End", 0)
		else:
			for to in node["go to"]:
				connect_node(node["node title"], 0, to, 0)
		
		
	
################## Save a file ####################################

# Compile data to be saved
func compile_nodes_into_json():
	
	var existing_nodes = get_tree().get_nodes_in_group("nodes")
	
	for node in existing_nodes:

		node.update_data()
		
		dialog[node.node_data["node title"]] = node.node_data
		var dialog_block = dialog[node.node_data["node title"]]
		
		print(dialog)
		
	return dialog
	

################## Menu/Navigation ####################################

# Get nodes
@onready var menu_list = $CanvasLayer/Panel/MenuList
@onready var options_list = $CanvasLayer/Panel/Options
@onready var new_file_dialog = $CanvasLayer/NewFileDialog
@onready var save_file_dialog = $CanvasLayer/SaveFileDialog
@onready var open_file_dialog = $CanvasLayer/OpenFileDialog
@onready var options_cancel_button = $CanvasLayer/Panel/CancelButton
@onready var options_panel = $CanvasLayer/Panel
@onready var back_button = $CanvasLayer/Panel/BackButton
@onready var save_button = $CanvasLayer/Panel/MenuList/Save

# Data
var new_font_size = Global.font_size
var new_type_sound = Global.type_sound

func _on_menu_toggled(button_pressed):
	if button_pressed:
		options_panel.show()
		
		# Disable SAVE if file does not exist
		save_button.disabled = not Global.if_file_exists(get_window().title)
			
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
	
func _on_new_pressed():
	new_file_dialog.show()



################## Connecting Nodes ####################################
func _on_connection_request(from_node, from_port, to_node, to_port):
	connect_node(from_node, from_port, to_node, to_port)
	if from_node != "Start":
		get_node(str(from_node)).node_data["go to"].append(to_node)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)
	get_node(str(from_node)).node_data["go to"].erase(to_node)

func clear_all():
	clear_connections()
	for node in get_tree().get_nodes_in_group("nodes"):
		node.queue_free()
	clear_node_count()
	graph_cleared.emit()
	
func auto_connect_start(node):
	if total_node_count == 1:
		connect_node("Start", 0, node, 0)
		
################## Tracking Node Count ####################################
func update_node_count(total = 0, dialog = 0, feature = 0, option = 0):
	total_node_count += total
	dialog_count += dialog
	feature_count += feature
	option_count += option
	
func clear_node_count():
	total_node_count += 0
	dialog_count += 0
	feature_count += 0
	option_count += 0
