extends GraphEdit

# Get nodes
@onready var last_instanced_node = $Start

# Keep Count
var dialog_node_count = 0

# Data
var dialog = {}

func _ready():
	
	# Window title
	DisplayServer.window_set_title("Untitled.json")
	
	
	
	
################## Creating a new node ####################################
func _on_new_node_pressed():
	var new_node = load("res://GraphNode.tscn")
	new_node = new_node.instantiate()
	add_child(new_node)
	
	dialog_node_count += 1
	new_node.title = "DIALOG_" + str(dialog_node_count)
	new_node.node_data["node title"] = new_node.title
	
	new_node.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	last_instanced_node = new_node
	
	
	
	
################## Creating a new feature ####################################
func _on_new_feature_pressed():
	var new_feature = load("res://Feature.tscn")
	new_feature = new_feature.instantiate()
	add_child(new_feature)
	
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
func _on_open_file_dialog_confirmed():
	
	# Replace window title
	DisplayServer.window_set_title("Untitled.json")
	
func load_load(file_path):
	# Nodes (incl. start & end nodes)
	# Features
	# Link connections 
	pass
	
	
	
	
################## Save a file ####################################

var save_path 

func _on_save_file_dialog_confirmed():
	
	# Replace window title
	DisplayServer.window_set_title(save_path)
	
	# Save data to the save_path
	save_as(save_path)

func save_as(file_path):
	pass

func _on_save_file_dialog_file_selected(path):
	save_path = path
	
	
	

################## Menu/Navigation ####################################
@onready var menu_list = $CanvasLayer/Panel/MenuList
@onready var options_list = $CanvasLayer/Panel/Options
@onready var save_file_dialog = $CanvasLayer/Panel/SaveFileDialog
@onready var open_file_dialog = $CanvasLayer/Panel/OpenFileDialog

func _on_cancel_button_pressed():
	$CanvasLayer/Panel.hide()

func _on_save_as_pressed():
	save_file_dialog.show()

func _on_open_pressed():
	open_file_dialog.show()

func _on_options_pressed():
	menu_list.hide()
	options_list.show()
	$CanvasLayer/Panel/CancelButton.hide()

func _on_cancel_pressed(): 
	pass # Replace with function body.


func _on_options_cancel_pressed():
	pass # Replace with function body.
