extends GraphNode

var node_type = "feature"

# Signal
signal _cancel_button_pressed(feature_type)

# Stats
var variable_count : int = 0
var signal_count : int = 0
var conditional_count : int = 0

# Data
var node_data = {
	"offset_x": 0,
	"offset_y": 0,
	"variables": {},
	"signals": [],
	"conditionals": {},
	"node title": "",
	"go to": []
}

func update_data():
	node_data["offset_x"] = self.position_offset.x
	node_data["offset_y"] = self.position_offset.y

	print("var count = " + str(variable_count) + ", signal count = " + str(signal_count) + ", conditional count = " + str(conditional_count))
	
	if variable_count != 0:
		for individual_variable in variables_group.get_children():
			if "Variable" in individual_variable.name:
				var var_active = individual_variable.get_node("CheckButton").button_pressed 
				var var_name = individual_variable.get_node("LineEdit").text 
				
				node_data["variables"][var_name] = var_active
		
	if signal_count != 0 :		
		for individual_signal in emit_signal_group.get_children():	
			if "Signal"	in individual_signal.name:
				var signal_name = individual_signal.get_node("LineEdit").text
				node_data["signals"].append(signal_name)

	if conditional_count != 0:
		for individual_conditional in conditionals_group.get_children():
			if "Conditional" in individual_conditional.name:
				var condition_exists = individual_conditional.get_node("CheckButton").button_pressed 
				var condition_name = individual_conditional.get_node("LineEdit").text 
				
				node_data["conditionals"][condition_name] = condition_exists

# Nodes
@onready var variables_group = $VariablesGroup
@onready var emit_signal_group = $EmitSignalGroup
@onready var conditionals_group = $ConditionalsGroup

@onready var variable = load("res://Variable.tscn")
@onready var emit_signal = load("res://Signal.tscn")
@onready var conditional = load("res://Conditional.tscn")


func _ready():
	variables_group.hide()
	emit_signal_group.hide()
	conditionals_group.hide()
	

############### 1 | GENERAL ##############################

# Cancelling features
func _on_cancel_button_pressed(feature_type):
	if "variable" in feature_type:
		variable_count -= 1
		
		if variable_count == 0:
			variables_group.hide()
		
	elif "signal" in feature_type:
		signal_count -= 1	
		
		if signal_count == 0:
			emit_signal_group.hide()
		
	elif "conditional" in feature_type:
		conditional_count -= 1
		
		if conditional_count == 0:
			conditionals_group.hide()
		
# Add Groups
func _on_add_button_pressed(feature_type):
	if feature_type == "variable":
		variable_count += 1
		
		var new_variable = variable.instantiate()
		new_variable.name = "Variable" + str(variable_count)
		variables_group.add_child(new_variable)
		
	elif feature_type == "signal":
		signal_count += 1	
		
		var new_emit_signal = emit_signal.instantiate()
		new_emit_signal.name = "Signal" + str(signal_count)
		emit_signal_group.add_child(new_emit_signal)
		
	elif feature_type == "conditional":
		conditional_count += 1
		var new_conditional = conditional.instantiate()
		new_conditional.name = "Conditional" + str(conditional_count)
		conditionals_group.add_child(new_conditional)


func _on_option_button_item_selected(index):
	if index == 0:
		variables_group.show()
		_on_add_button_pressed("variable")
		
	elif index == 1: 
		emit_signal_group.show()
		_on_add_button_pressed("signal")
		
	else:
		conditionals_group.show()
		_on_add_button_pressed("conditional")
