extends GraphNode


var node_data = {
	"offset_x": 0,
	"offset_y": 0,
	"character": "",
	"text": "",
	"line asset": "",
	"node title": ""
}

func _on_close_request():
	get_parent().dialog_node_count -= 1
	queue_free()

func _on_dragged(from, to):
	position_offset = to


func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize

func _on_slot_updated(idx):
	pass # Replace with function body.

func _on_option_button_item_selected(index):
	pass # Replace with function body.
