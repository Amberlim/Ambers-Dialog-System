extends GraphNode

var node_type = "node"
var rng = RandomNumberGenerator.new()

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
	get_parent().dialog_node_count -= 1
	queue_free()

func _on_dragged(from, to):
	position_offset = to
	
	var drag_sound = $DragSound
	drag_sound.pitch_scale = random_number()
	drag_sound.play()
	
func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize
	
func _on_option_button_item_selected(index):
	node_data["character"] = character.get_item_text(index)

func update_data():
	node_data["offset_x"] = position.x
	node_data["offset_y"] = position.y
	node_data["text"] = text.text
	node_data["line asset"] = line_asset.text

func random_number():
	return rng.randf_range(1, 1.5)

