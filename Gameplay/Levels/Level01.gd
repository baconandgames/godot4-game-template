extends Node2D


func _process(_delta: float) -> void:
	var parent = get_parent()
	var child_count:int = parent.get_child_count()
	if  child_count - 1 != get_index() - 1:
		parent.move_child(self, child_count - 1)
