extends HBoxContainer

@export var text : LineEdit

func _on_cancel_button_pressed():
	get_parent().get_parent()._cancel_button_pressed.emit(get_parent().name.to_lower())
	print(get_parent().name)
	queue_free()
	

