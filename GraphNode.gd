extends GraphNode

func _on_close_request():
	queue_free()


func _on_dragged(from, to):
	position_offset = to


func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize

func _on_slot_updated(idx):
	pass # Replace with function body.
