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
	get_parent().dialog_node_count -= 1
	queue_free()

func _on_dragged(from, to):
	position_offset = to

	
func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize
	
func update_data():
	node_data["text"] = text.text

