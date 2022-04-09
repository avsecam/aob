extends Spatial


func _ready():
	_set_collisions(self)


func _set_collisions(head: Spatial):
	# only set collisions on StaticBodies
	for element in head.get_children():
		if element.get_class() == "StaticBody":
			element.set_collision_layer_bit(0, false)
			element.set_collision_layer_bit(1, true)
		else:
			_set_collisions(element)
