extends Control
class_name PlayerTurnIndicator

## Class for handling illustration indicating which turn it is.

@export_group("Position")

## Position of sprite when hiding the indicator.
@export var hide_pos: Vector2 = Vector2(-500,-580)

## Position of sprite when showing the indicator.
@export var show_pos: Vector2 = Vector2(50,-580)

## Holds the texture node
@onready var sprite: TextureRect = $PlayerTurnSprite

## Holds the tween duration
var anim_dur: float = 1.0

## Hides sprite
func hide_sprite():
	## Animates using tween.
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(sprite, "position", hide_pos, anim_dur)


## Shows sprite, accepts sprite texture as argument.
func show_sprite(texture = null):
	## Sets sprite's texture if texture is not null.
	if texture != null:
		sprite.set_texture(texture)
	
	## Animates sliding in.
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(sprite, "position", show_pos, anim_dur)


func _ready():
	## Sets sprite's position to the initial hide pos.
	sprite.set_position(hide_pos)
