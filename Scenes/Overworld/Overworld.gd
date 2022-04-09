extends Spatial


onready var world = $World


func _ready():
	PlayerData.location = world.filename
	_set_world_collisions()


func _set_world_collisions():
	for worldElement in world.get_children():
		if worldElement.get_class() == "StaticBody":
			worldElement.set_collision_layer_bit(0, false)
			worldElement.set_collision_layer_bit(1, true)
