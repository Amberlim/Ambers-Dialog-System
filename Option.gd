extends GraphNode

var node_type = "option"

#@export var text : CodeEdit
@onready var text = $Text/TextEdit

var node_data = {
	"offset_x": 0,
	"offset_y": 0,
	"text": "",
	"go to": []
}

func _on_close_request():
	# Delete overall dialog node count
	get_parent().update_node_count(-1)

	# Get current node number
	var node_prefix = "OPTION_"
	var node_number = int(name.lstrip(node_prefix))
	var current_node = node_prefix + str(node_number)

	# Get the > numbers from the node names and put them into an array
	var node_array = []
	for node in get_tree().get_nodes_in_group("OPTION"):
		# Ignore the current node (not yet freed)
		if node.name != current_node:
			# Get only the > numbers
			var other_node_number = int(node.name.lstrip(node_prefix))
			if other_node_number > node_number:
				node_array.append(other_node_number)

	# Subtract the name, title and ID of > nodes by 1
	for number in node_array:
		var node = get_parent().get_node(node_prefix + str(number))
		var new_number = number - 1
		var new_name = node_prefix + str(new_number)
		node.name = new_name
		node.title = new_name
		node.node_data["node title"] = new_name

	# Queue free
	get_parent().update_node_count(0, 0, 0, -1)
	queue_free()

func _on_dragged(from, to):
	position_offset = to

	
func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize
	
func update_data():
	node_data["text"] = text.text

	node_data["offset_x"] = position_offset.x
	node_data["offset_y"] = position_offset.y
