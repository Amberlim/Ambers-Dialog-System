extends GraphEdit

@onready var last_instanced_node = $Start

func _on_new_node_pressed():
	var new_node = load("res://GraphNode.tscn")
	new_node = new_node.instantiate()
	add_child(new_node)
	
	new_node.position_offset = last_instanced_node.position_offset + Vector2(500,10)
	
	last_instanced_node = new_node
	
	
	
	

