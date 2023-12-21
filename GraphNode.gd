extends GraphNode

var node_type = "node"

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
	get_parent().dialog_node_count -= 1
	queue_free()

func _on_dragged(from, to):
	position_offset = to


func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize
	
func _on_option_button_item_selected(index):
	node_data["character"] = $Character/Character/OptionButton.get_item_text(index)

func update_data():
	node_data.text = $Text/TextEdit.text
	node_data.line_asset = $LineAsset/LineEdit.text
