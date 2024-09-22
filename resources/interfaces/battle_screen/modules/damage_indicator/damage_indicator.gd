extends Control

## Class for damage indicator.
## Displays damage or miss, plays a tween animation to move up a bit,
## then queue_free.


## Holds the damage text node and its value
@onready var damage_text_node: Label = $DamageText
var damage_text: String

## Holds tween duration
var anim_dur: float = 1


## Sets up damage indicator, accepts the damage text.
## Damage text will contain the amount of damage or "MISS" if the attack
## missed.
func setup(text: String, pos: Vector2):
	damage_text = text
	set_position(pos)


func _ready():
	## Sets damage text node's value
	damage_text_node.set_text(damage_text)
	## Creates tween
	var tween: Tween = create_tween()
	
	## Animates fading out and moving up
	tween.set_parallel(true)
	tween.tween_property(
		self, "position", position + Vector2(0,-40), anim_dur
	).from_current()
	tween.tween_property(
		self, "modulate:a", 0, anim_dur
	)
	
	## Queue free when done
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
