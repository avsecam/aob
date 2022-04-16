extends Spatial


onready var sprite: AnimatedSprite3D = $Sprite

export var spriteFrames: SpriteFrames
var characterStats: CharacterStats


func _ready():
	if spriteFrames != null:
		sprite.frames = spriteFrames
