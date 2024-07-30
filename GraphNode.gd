extends GraphNode

var node_type = "node"

#@export var text : CodeEdit
@onready var text = $Text/TextEdit
@onready var character = $Character/Character/OptionButton
@onready var line_asset = $LineAsset/LineEdit
	

var node_data = {
	"offset_x": 0,
	"offset_y": 0,
	"character": "",
	"text": "",
	"line asset": "",
	"node title": "",
	"go to": []
}

func _on_close_request():

	# Delete overall dialog node count
	get_parent().update_node_count(-1)

	# Get current node number
	var node_prefix = "DIALOG_"
	var node_number = int(name.lstrip(node_prefix))

	# Get the > numbers from the node names and put them into an array
	var node_array = []
	for node in get_tree().get_nodes_in_group("DIALOG"):
		# Ignore the current node (not yet freed)
		if node.name != self.name:
			# Get only the > numbers
			var other_node_number = int(node.name.lstrip(node_prefix))
			if other_node_number > node_number:
				node_array.append(other_node_number)

	# Subtract the name, title and ID of > nodes by 1
	for number in node_array:
		print(node_array)
		get_parent().update_node_name(node_prefix, number)
		print("Getting rid of " + self.name)

	# Queue free
	get_parent().update_node_count(0, -1)
	queue_free()

func _on_dragged(from, to):
	position_offset = to
	
func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize
	
func _on_option_button_item_selected(index):
	node_data["character"] = character.get_item_text(index)

func update_data():
	node_data["offset_x"] = position_offset.x
	node_data["offset_y"] = position_offset.y
	
	node_data["text"] = text.text
	node_data["line asset"] = line_asset.text

