extends GraphNode

# Signal
signal _cancel_button_pressed(feature_type)

# Stats
var variable_count : int = 0
var signal_count : int = 0
var conditional_count : int = 0

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
		variables_group.add_child(new_variable)
		
	elif feature_type == "signal":
		signal_count += 1	
		
		var new_emit_signal = emit_signal.instantiate()
		emit_signal_group.add_child(new_emit_signal)
		
	elif feature_type == "conditional":
		conditional_count += 1
		
		var new_conditional = conditional.instantiate()
		conditionals_group.add_child(new_conditional)


func _on_option_button_item_selected(index):
	if index == 0:
		variables_group.show()
		variable_count += 1
		
	elif index == 1: 
		emit_signal_group.show()
		signal_count += 1
		
	else:
		conditionals_group.show()
		conditional_count += 1
