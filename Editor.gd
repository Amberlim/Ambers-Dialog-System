extends GraphEdit

# Get nodes
var last_instanced_node_pos = Vector2(0,0)
var last_mouse_pos = Vector2(0,0)
@onready var saved_notification = $Tool/SavedNotification
@onready var spawn_sound = $SpawnSound
var rng = RandomNumberGenerator.new()


# Keep Count
var total_node_count = 0
var end_count = 0
var new_nodes_position_offset = Vector2(450,0)


# Data
var dialog = {}
var node_stack:Dictionary = {
	"DIALOG":  { "nodes": [], "last_index": 0, "res": load("res://GraphNode.tscn") },
	"FEATURE": { "nodes": [], "last_index": 0, "res": load("res://Feature.tscn") },
	"OPTION":  { "nodes": [], "last_index": 0, "res": load("res://Option.tscn") }
}

# Signals
signal graph_cleared
signal node_closed

var selected_file_path:String
func _ready():
	if get_node("CanvasLayer/OpenFileDialog").is_connected("file_selected", _on_file_dialog_file_selected):
#		get_node("CanvasLayer/OpenFileDialog").disconnect("file_selected", _on_file_dialog_file_selected)
		print("Signal: file_selected - This signal is only used to set the path")
	get_node("CanvasLayer/OpenFileDialog").connect("confirmed", _on_file_dialog_load_file)

################## Shortcut Keys ####################################
	
func _input(event):
	# Get actaul position = (mouse position in window + moved canvas position) scaled 
	var mouse_position_in_canvas = (get_global_mouse_position() + scroll_offset)/zoom
	if Input.is_action_just_released("New Node"):
		last_mouse_pos = mouse_position_in_canvas - new_nodes_position_offset
		_on_new_node_pressed()
	elif Input.is_action_just_released("Return to Start"):
		scroll_offset = Vector2(-200, -40)
	elif Input.is_action_just_released("Go to End"):
		if has_node("End"):
			var end = $End
			var pos_x = end.position.x
			pos_x = pos_x * -1
			var pos_y = end.position.y
			pos_y = pos_y * -0.02
			scroll_offset = Vector2(pos_x, pos_y)
	elif Input.is_action_just_released("New File"):
		_on_new_pressed()
	elif Input.is_action_just_released("New Feature"):
		last_mouse_pos = mouse_position_in_canvas - new_nodes_position_offset
		_on_new_feature_pressed()
	elif Input.is_action_just_released("Open"):
		$CanvasLayer/OpenFileDialog.show()
	elif Input.is_action_just_released("Save"):
		if Global.if_file_exists(get_window().title) == false:
			_on_save_as_pressed()
		else:
			save_file_dialog.file_path = get_window().title
			save_file_dialog._on_save_pressed()
			saved_notification.get_node("AnimationPlayer").play("FadeOut")


func random_number():
	return rng.randf_range(1, 1.5)

################## Life cycle methods  ####################################
# Called when a node is either created or removed
func update_node_count():
	var node_count = 0
	var single_node = null

	for key in node_stack.keys():
		var type_node_count = len(node_stack[ key ].nodes)
		node_count = node_count + type_node_count

		if type_node_count == 1:
			single_node = node_stack[ key ].nodes[0].get_name()

	total_node_count = node_count

	# single_node is implicit by count but still good practice to declare in statement
	if total_node_count == 1 and single_node:
		auto_connect_start(single_node)

# General method to create nodes (DIALOG | FEATURE | OPTION) - see: var node_stack
# + accepts a name as passive, generates a new name if empty
func get_new_node(type:String, _node_name:String = ""):
	var new_node = node_stack[type].res.instantiate()
	node_stack[ type ].last_index = node_stack[ type ].last_index + 1

	var new_name = type + "_" +str(node_stack[ type ].last_index).lpad(10,"0")
	if _node_name != "":
		new_name = _node_name

	new_node.title =  new_name
	new_node.name = new_name
	new_node.node_data["node title"] =  new_name
	node_stack[ type ].nodes.push_back(new_node)

	if last_mouse_pos != Vector2(0,0): # Set mouse position as origin if event was a click
		last_instanced_node_pos = last_mouse_pos
		last_mouse_pos = Vector2(0,0) # Unset mouse position
	else: # Recreate bounds if the event comes from a button
		var bounds:Vector2 = Vector2(0, 0)
		for key in node_stack.keys():
			for node in node_stack[ key ].nodes:
				if node.position_offset.x > bounds.x:
					bounds.x = node.position_offset.x
				if node.position_offset.y > bounds.y:
					bounds.y = node.position_offset.y
		last_instanced_node_pos = bounds

	add_child(new_node)
	update_node_count()

	return new_node

# Called from child only, passes itself and lets GraphEdit handle the removal
# For future reference _on_close_request(): get_parent().remove_node(self)
func remove_node(node:Node):
	var type = node.get_name().split("_")[0]
	if node_stack.has(type):
		var index = node_stack[ type ].nodes.find(node)

		if index == -1:
			push_error("Node not found on stack (" + str(node.get_path()) + ")")
		else:
			node_stack[ type ].nodes.remove_at(index)

			var node_name = node.get_name()
			for connection in get_connection_list():
				if connection.from == node_name or connection.to == node_name:
					disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
			node.queue_free()
			update_node_count()
	else:
		push_error("Node type not found (" + type + ")")

################## Creating a new node ####################################
func _on_new_node_pressed(open_save : bool = false):
	
	spawn_sound.pitch_scale = random_number()
	spawn_sound.play()

	var new_node = get_new_node("DIALOG")

	if not open_save:
		if last_instanced_node_pos == Vector2(0,0):
			last_instanced_node_pos = $Start.position_offset
		new_node.position_offset = last_instanced_node_pos + new_nodes_position_offset

################## Creating a new feature ####################################
func _on_new_feature_pressed(open_save : bool = false):
	spawn_sound.pitch_scale = random_number()
	spawn_sound.play()
	
	var new_feature = get_new_node("FEATURE")
	
	if not open_save:
		if last_instanced_node_pos == Vector2(0,0):
			last_instanced_node_pos = $Start.position_offset
		new_feature.position_offset = last_instanced_node_pos + new_nodes_position_offset 

################## Creating a new option ####################################
func _on_new_option_pressed(open_save : bool = false):
	spawn_sound.pitch_scale = random_number()
	spawn_sound.play()
	
	var new_option = get_new_node("OPTION")

	
	if not open_save:
		if last_instanced_node_pos == Vector2(0,0):
			last_instanced_node_pos = $Start.position_offset
		new_option.position_offset = last_instanced_node_pos + new_nodes_position_offset
 
################## Ending the dialog ####################################
func _on_end_node_pressed():
	if end_count == 0: 
		
		end_count += 1
		
		spawn_sound.pitch_scale = random_number()
		spawn_sound.play()
		
		var end_node = load("res://End.tscn")
		end_node = end_node.instantiate()
		add_child(end_node)
		
		end_node.position_offset = last_instanced_node_pos + new_nodes_position_offset
		
		last_instanced_node_pos = end_node.position_offset


################## Open file ####################################
	
func _on_file_dialog_file_selected(path):
	selected_file_path = path

func _on_file_dialog_load_file():
	# Change window title
	get_window().title = selected_file_path.get_file().replace(".json", "")
	# Make sure the listener runs before the emitter
	_on_file_dialog_load_file_async() # Start the async function waiting for the signal
	clear_all() # Run the function that emits the signal expected
	
func _on_file_dialog_load_file_async():
	await self.graph_cleared
	# Hide Option Panel
	options_panel.hide()
	
	# Parse JSON to *dialog* dictionary in scene tree
	var file = FileAccess.open(selected_file_path,FileAccess.READ)
	var dialog = JSON.parse_string(file.get_as_text())
	
	
	# Assign nodes into/with correct positions and values
	# Nodes (incl. start & end nodes)
	
	# Create nodes before connecting them to avoid lost references
	for node_name in dialog:
		var type = node_name.split("_")[0]
		if type and node_stack.has(type):
			var new_node = get_new_node(type, node_name)
			var node_data_keys = dialog[ node_name ].keys()
			# reassign node"s data
			for key in node_data_keys:
				new_node.node_data[ key ] = dialog[ node_name ][ key ]
			# pass to object for next loop quick reference
			dialog[ node_name ].res = new_node

	for node_name in dialog:
		var node = dialog[node_name]
		
		# if type: node
		if "DIALOG" in node["node title"]:
			var current_node = dialog[ node_name ].res

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
			var current_node = dialog[ node_name ].res
			
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
					variable_node.check_button.button_pressed = node["variables"].values()[current_variable_count - 1]
			
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
			var current_node = dialog[ node_name ].res

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
	for type in node_stack.keys():
		for node in node_stack[type].nodes:
			node.queue_free()
		node_stack[ type ].last_index = 0
		node_stack[type].nodes = []
	await get_tree().create_timer(0.05).timeout
	total_node_count = 0
	graph_cleared.emit()

func auto_connect_start(node):
	connect_node("Start", 0, node, 0)
