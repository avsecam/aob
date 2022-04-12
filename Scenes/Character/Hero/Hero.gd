extends Spatial


onready var sprite: AnimatedSprite3D = $Sprite

export var spriteFrames: SpriteFrames


func _ready():
	sprite.frames = spriteFrames if spriteFrames != null else sprite.frames
