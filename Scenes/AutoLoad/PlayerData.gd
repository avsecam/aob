extends Node


const WALK_SPEED: float = 5.0
const FALL_ACCELERATION: float = 75.0
const JUMP_IMPULSE: float = 25.0
const FRICTION: float = 0.2

var location: String  # which level/stage
var position: Vector3 # which x,y,z coordinate
var rotation: Vector3

var activeCharacter

var inBattle: bool = false
