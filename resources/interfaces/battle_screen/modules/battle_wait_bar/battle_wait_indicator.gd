extends Control
class_name BattleWaitIndicator

## Class for battle wait indicator.
## Will spawn a texture, move that texture from A to B, infinitely

## Stores the character's node name that is tied to this wait indicator.
var char_node_name: String

## Stores origin and destination points
var origin: Vector2 = Vector2(0,0)
var dest: Vector2 = Vector2(0,0)

## Stores the time availabe for the indicator to reach the destination
var time: float

## Stores texture for the indicator
var texture: Texture2D

## Stores tween
var tween: Tween

## Stores texture's node
@onready var texture_node: TextureRect = $Texture


func _ready():
	## Sets indicator's texture and texture size
	texture_node.set_texture(texture)
	
	## Begins moving texture
	_move_texture()


## Pauses current tween animation
func pause_tween():
	tween.pause()
	

## Resumes tween animation
func resume_tween():
	tween.play()


## Sets indicator's origin and destination points
func set_points(origin: Vector2, dest: Vector2):
	self.origin = origin
	self.dest = dest


## Sets indicator's time
func set_time(time: float):
	self.time = time


## Sets texture
func set_indicator_texture(texture: Texture2D):
	self.texture = texture


## Moves texture from point A to B, then call itself back
func _move_texture():
	## Begins animation using tween
	tween = create_tween()
	tween.tween_property(self, "position", dest, time).from(origin)
	tween.tween_callback(queue_free)
